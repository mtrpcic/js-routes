desc "Generate a JavaScript file that contains your Rails routes"
namespace :js do
  task :routes, [:filename] => :environment do |t, args|
    filename = args[:filename].blank? ? "rails_routes.js" : args[:filename]
    if Rails.version >= "3.0.0"
      save_path = "#{Rails.root}/app/assets/javascripts/#{filename}"
      routes = generate_routes_for_rails_3
    else
      save_path = "#{RAILS_ROOT}/public/javascripts/#{filename}"
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
  
  js_func = %{
  function #{name}_path(options){
    if(options && options.data) {
      var op_params = []
      for(var key in options.data){
        op_params.push([key, options.data[key]].join('='));
      }
      var params = options.params;
      return '#{path}?' + op_params.join('&');
    }else if(options && options.params) {
      var params = options.params;
      return '#{path}'
    }else {
      var params = options;
      return '#{path}'
    }
  }}
  return js_func
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
    processed_routes << {:name => route.name, :path => route.path.spec.to_s.split("(")[0]} unless route.name.nil?
  end
  return processed_routes
end

