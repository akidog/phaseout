require 'action_dispatch'
require 'action_dispatch/routing/inspector'

module Phaseout
  def self.routes
    return @routes if @routes

    @routes = Rails.application.routes.routes.map do |route|
      Phaseout::RouteWrapper.new route
    end.find_all do |route|
      route.not_internal? && route.verb.downcase.match(/get/)
    end
  end

  def self.route_tree
    return @route_tree if @route_tree
    @route_tree = Hash.new
    routes.each do |route|
      last_hash = @route_tree
      route.tokens.each do |type, value|
        last_hash = ( last_hash[ [type, value] ] ||= Hash.new )
      end
      last_hash[:routes] ||= []
      last_hash[:routes] << route.to_s
    end
    @route_tree
  end

  def self.title_tree_source
    TitleTreeGenerator.new(route_tree).call
  end

  class TitleTreeGenerator
    def initialize(route_tree)
      @route_tree   = route_tree
      @nested_level = 0
      @result       = ''
    end

    def call
      puts 'Phaseout.title_builder do'
      visit @route_tree
      puts 'end'
      @result
    end

    def ignore_node?(node)
      node.nil? || ( node.size == 1 && node[ [:symbol, ':format'] ] )
    end

    def visit(node)
      nest do
        if node.is_a? Hash
          node.each do |(type, value), other_node|
            case type
            when :literal
              if ignore_node? other_node
                puts "path '#{value}'"
              else
                puts "path '#{value}' do"
                visit other_node
                puts 'end'
              end
            when :symbol
              if value != ':format'
                puts "token '#{value}' do"
                visit other_node
                puts 'end'
              end
            end
          end
        else
          node.each do |value|
            puts "# #{value}"
          end
        end
      end
    end

    def nest(&block)
      @nested_level += 1
      yield
      @nested_level -= 1
    end

    def puts(string)
      @result << ( ' '*@nested_level*2 + string + "\n" )
    end
  end

  class RouteWrapper < ActionDispatch::Routing::RouteWrapper
    def not_internal?
      !internal?
    end

    def tokens
      return @tokens if @tokens
      get_tokens
      @tokens
    end

    def inspect
      "#<Route #{controller}##{action} #{path}>"
    end
    alias :to_s :inspect

    protected
    def get_tokens
      @tokens = []
      RoutesTree.new(self).accept __getobj__.path.spec
    end
  end

  class RoutesTree < ActionDispatch::Journey::Visitors::Visitor

    def initialize(route_wrapper)
      @route_wrapper = route_wrapper
      super()
    end

    private
    def visit_GROUP(node)
      visit node.left
    end

    def terminal(node)
      # @route_wrapper.tokens << [ node.type.to_s.downcase.to_sym, node.left.to_s ]
      case node.type
      when :LITERAL
        @route_wrapper.tokens << [ :literal, node.left.to_s ]
      # when :SLASH
      #   @route_wrapper.tokens << [ :slash ]
      when :SYMBOL
        @route_wrapper.tokens << [ :symbol, node.left.to_s ]
      end
    end

    def binary(node)
      visit node.left
      visit node.right
    end

    def nary(node)
      node.children.map{ |c| visit c }
    end
  end
end