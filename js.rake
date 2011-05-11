desc "Generate a JavaScript file that contains your Rails routes"
namespace :js do
  task :routes, :filename, :needs => :environment do |t, args|
    filename = args[:filename].blank? ? "rails_routes.js" : args[:filename]
    save_path = "#{RAILS_ROOT}/public/javascripts/#{filename}"
    if Rails.version >= "3.0.0"
      routes = generate_routes_for_rails_3
    else
      routes = generate_routes_for_rails_2
    end

    javascript = ""
    routes.each do |route|
        javascript << generate_method(route[:name], route[:path]) + "\n"
    end

    File.open(save_path, "w") { |f| f.write(javascript) }
    puts "Routes saved to #{save_path}."
  end
end

def generate_method(name, path)
  compare = /:(.*?)(\/|$)/
  path.sub!(compare, "' + params.#{$1} + '#{$2}") while path =~ compare
  return "function #{name}(params){ return '#{path}'}"
end

def generate_routes_for_rails_2
  processed_routes = []
  ActionController::Routing::Routes.routes.each do |route|
    name = ActionController::Routing::Routes.named_routes.routes.index(route)
    segs = route.segments.inject("") {|str, s| str << s.to_s}
    segs.chop! if segs.length > 1
    processed_routes << {:name => name, :path => segs.split("(")[0]} unless name.nil?
  end
  return processed_routes
end

def generate_routes_for_rails_3
  Rails.application.reload_routes!
  processed_routes = []
  Rails.application.routes.routes.each do |route|
    processed_routes << {:name => route.name + "_path", :path => route.path.split("(")[0]} unless route.name.nil?
  end
  return processed_routes
end

