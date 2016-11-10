
namespace :jurisdictions do
  jurisdictions = { 'County Court': 'County',
                    'High Court': 'High',
                    'Family Court': 'Family',
                    'Magistrates Civil': 'Magistrates',
                    'Employment Tribunal': 'Employment',
                    'Gender Tribunal': 'Gender recognition',
                    'Land & Property Chamber': 'Property',
                    'Immigration Appeal Chamber': 'Immigration (first-tier)',
                    'Family SFC': 'Family',
                    'Upper Tribunal Immigration Appeal Chamber': 'Immigration (upper)' }

  desc 'populate the db with the new jurisdiction names'
  task add_new_names: :environment do
    jurisdictions.each do |old_name, new_name|
      puts '-' * 80
      puts "looking for #{old_name}..."
      jurisdiction = Jurisdiction.where(name: old_name).first

      next if jurisdiction.nil?

      puts "found #{old_name}, assigning it #{new_name}"
      jurisdiction.name = new_name
      jurisdiction.save!
      puts 'saved.'
    end

    jurisdiction = Jurisdiction.where(name: 'Court of Protection').first
    jurisdiction&.destroy
  end

  desc 'revert back the old jurisdiction names'
  task revert_old_names: :environment do
    jurisdictions.invert.each do |new_name, old_name|
      puts '-' * 80
      puts "looking for #{new_name}..."
      jurisdiction = Jurisdiction.where(name: new_name).first

      next if jurisdiction.nil?

      puts "found #{new_name}, re-assigning it #{old_name}"
      jurisdiction.name = old_name
      jurisdiction.save!
    end

    Jurisdiction.create(name: 'Court of Protection', abbr: 'COP')
  end
end
