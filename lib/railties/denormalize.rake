namespace :db do
  desc "Verify all denormalizations and repair any inconsistencies"
  task :denormalize => :environment do
    get_denormalizable_models.each do |klass|
      if klass.embedded?
        reflection = klass.reflect_on_all_associations(:embedded_in).first
        parent     = reflection.class_name.to_s.classify.constantize
        
        unless parent.embedded?
          parent.all.each do |parent_instance|
            parent_instance.send(reflection.inverse).each(&:repair_denormalized!)
          end
        end
      else
        klass.all.each do |instance|
          instance.repair_denormalized!
        end
      end
    end
  end
  
  def get_denormalizable_models
    documents = []
    Dir.glob("app/models/**/*.rb").sort.each do |file|
      model_path = file[0..-4].split('/')[2..-1]
      begin
        klass = model_path.map(&:classify).join('::').constantize
        
        if klass.ancestors.include?(Mongoid::Document) && klass.ancestors.include?(Mongoid::Denormalize)
          documents << klass
        end
      rescue => e
        # Just for non-mongoid objects that dont have the embedded
        # attribute at the class level.
      end
    end
    documents
  end
end