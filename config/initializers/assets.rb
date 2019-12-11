# Be sure to restart your server when you modify this file.

# Version of your assets, change this if you want to expire all your assets.
Rails.application.config.assets.version = '1.0'

# Add additional assets to the asset load path.
# Rails.application.config.assets.paths << Emoji.images_path
# Add Yarn node_modules folder to the asset load path.
Rails.application.config.assets.paths << Rails.root.join('node_modules')

Rails.application.config.assets.precompile += %w( reset.css )
Rails.application.config.assets.precompile += %w( style.css )
Rails.application.config.assets.precompile += %w( prettyPhoto.css )
Rails.application.config.assets.precompile += %w( bootstrap.css )

Rails.application.config.assets.precompile += %w( bootstrap.js )
Rails.application.config.assets.precompile += %w( prettyPhoto.js )
Rails.application.config.assets.precompile += %w( script.js )

Rails.application.config.assets.precompile += %w( hypertree.css )
Rails.application.config.assets.precompile += %w( jit.min.js )
Rails.application.config.assets.precompile += %w( hypertree.js )

# map data
Dir.glob(Rails.root.join('app', 'assets', 'javascripts', 'map_data', '*')).each do |path|
  Rails.application.config.assets.precompile << path
end

# map icons
icons = Dir.glob(Rails.root.join('app', 'assets', 'images', 'map_directory'))
Rails.application.config.assets.precompile += icons

# map
Rails.application.config.assets.precompile += %w( leaflet-1.6.0.css )
Rails.application.config.assets.precompile += %w( leaflet-1.6.0.min.js )
Rails.application.config.assets.precompile += %w( markercluster-1.4.1.min.js )
Rails.application.config.assets.precompile += %w( markercluster-1.4.1.css )
Rails.application.config.assets.precompile += %w( map.css )
Rails.application.config.assets.precompile += %w( map.js )

Rails.application.config.assets.precompile += %w( jquery-ui.min.js )
Rails.application.config.assets.precompile += %w( jquery-ui.css )
Rails.application.config.assets.precompile += %w( defiant.min.js )

Rails.application.config.assets.precompile += %w(*.png *.jpg *.jpeg *.gif)
