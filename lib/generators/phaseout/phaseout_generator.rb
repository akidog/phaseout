class PhaseoutGenerator < Rails::Generators::Base
  source_root File.expand_path("../templates", __FILE__)

  desc 'Setup config for Phaseout gem'

  def create_initializer_file
    create_file 'config/initializers/phaseout_title_builder.rb', Phaseout.title_tree_source
  end

  def copy_locale_file
    copy_file 'phaseout.yml', 'config/locales/phaseout.yml'
  end
end
