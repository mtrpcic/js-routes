desc "Generate a JavaScript file that contains your Rails routes"
namespace :js do
  task :routes, [:filename] => [:environment] do |t, args|
    if Rails.version < "3.1.0"
      puts "Your Rails version is not supported."
      exit 1
    end

    filename = args[:filename].blank? ? "rails_routes.js" : args[:filename]
    save_path = "#{Rails.root}/app/assets/javascripts/#{filename}"

    routes = generate_routes

    javascript = "var Paths = {\n";
    javascript << routes.map do |route|
      generate_method(route[:name], route[:path])
    end.join(",\n")

    javascript << "\n};";

    File.open(save_path, "w") { |f| f.write(javascript) }
    puts "Routes saved to #{save_path}."
  end
end

def generate_method(name, path)
  compare = /:(.*?)(\/|$)/
  path.sub!(compare, "' + params.#{$1} + '#{$2}") while path =~ compare
  return "\t#{name}: function(params) {return '#{path}';}"
end

def generate_routes
  Rails.application.reload_routes!
  processed_routes = []
  Rails.application.routes.routes.each do |route|
    processed_routes << {:name => route.name.camelize(:lower), :path => route.path.split("(")[0]} unless route.name.nil?
  end
  return processed_routes
end