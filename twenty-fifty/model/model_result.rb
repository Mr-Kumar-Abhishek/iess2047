require_relative 'model'

class ModelResult < ModelUtilities  
  attr_accessor :excel, :pathway
  
  def initialize
    @excel = Model.new
  end
  
  def self.calculate_pathway(code)
    new.calculate_pathway(code)
  end
  
  def calculate_pathway(code)
    Thread.exclusive do 
      reset
      @pathway = { _id: code, choices: set_choices(code) }
      sankey_table
      primary_energy_tables #DONE
      electricity_tables #DONE
      #heating_choice_table - #Removed
      #cost_components_table  #Removed
      #map_table #
      #energy_imports #DONE
      #energy_diversity Non priority
      #air_quality #YES        6

      #******   ADDING FUNCTION WARNING HERE ****
      dependencies
      emissions_do_nothing
      land_do_nothing
      energy_share
      emissions_absolute
      emissions_percapita
      import_costs
      import_proportions
      electricity_percapita
      population


    end
    return pathway
  end
      
  def sankey_table
    s = {} 
    #(6..94).each do |row|
    j = 2012
    ('f'..'m').each do |num| 
    s[j] = []
      (6..85).each do |row|
        s[j] << [r("flows_c#{row}"),r("flows_#{num}#{row}"),r("flows_d#{row}")] #changed n to m (2052 to 2047)
      end
    j += 5
    end
    pathway[:sankey] = s
  end
  
  def primary_energy_tables
    #pathway[:ghg] = table 198, 210 #194, 206 #182, 192
    pathway[:final_energy_demand] = table 7, 20 #7, 18 #13, 18   Includes total
    
    # MISSING ?
    pathway[:primary_energy_supply] = table 248, 258 #308, 321 #283, 296 India - > N.01 to Total Primary supply
    
    # MISSING ?
	  pathway[:demand_do_nothing] = table 22, 22 # Demand do nothing scenario
    
    # MISSING ?
	  pathway[:supply_do_nothing] = table 261, 261 # Supply do nothing scenario
    
	  pathway[:conversion_losses] = table 52, 52
	  pathway[:distribution_losses] = table 53,53 # Distribution losses and own use
    #pathway[:emissions_absolute] = table 184, 192 #Emissions Absolute
    #pathway[:emissions_percapita] = table 313, 319
    #pathway[:import_costs] =  table 340, 342
    #pathway[:ghg][:percent_reduction_from_1990] = (r("intermediate_output_bh155") * 100).round  #not done for India version
  end


  def emissions_absolute
    emissions_abs = {}
    (300..309).each do |row|        #includes total
      emissions_abs[label("intermediate_output", row)] = annual_data("intermediate_output", row)
    end
    pathway['emissions_absolute'] = emissions_abs
  end

  def import_proportions
    imp_pro = {}
    (378..381).each do |row| #includes total
      imp_pro[label("intermediate_output", row)] = annual_data("intermediate_output", row)
    end
    pathway['import_proportions'] = imp_pro

  end

  def emissions_percapita
    emissions_per = {}
    (314..323).each do |row|                   #includes total
      emissions_per[label("intermediate_output", row)] = annual_data("intermediate_output", row)
    end
    pathway['emissions_percapita'] = emissions_per
  end

  def import_costs
    imp_costs = {}
    (348..351).each do |row|                                      #includes total
      imp_costs[label("intermediate_output", row)] = annual_data("intermediate_output", row)
    end
    pathway['import_costs'] = imp_costs
  end



  def electricity_tables
    e = {}
    # MISSING
    e[:demand] = table 287, 293 #347, 353 #322, 326     includes total
    
    # MISSING
    e[:supply] = table 360, 374 #107, 125 #96, 111
    #e[:emissions] = table 200, 210 #295, 298 #270, 273  -> Emissions reclassified
    #e[:capacity] = table 135, 150 #131, 146 #118, 132 -> GW installed capacity
    
	  e[:re_share_percent] = table 125, 125 #-> Percentage Share of Renewables
	  e[:electricity_exports] = table 126, 126 #-> electricity exports
    #e['automatically_built'] = r("intermediate_output_bh120") Not used
    #e['peaking'] = r("intermediate_output_bh145") #Not used
    pathway['electricity'] = e
  end


  def land_do_nothing
    land = {}
    (37..40).each do |row|
      land[label("land_use", row)] = [r("land_use_j#{row}"),r("land_use_k#{row}")]
    end
    pathway['land_do_nothing'] = land
  end

  def electricity_percapita
    elec = {}
    (397..402).each do |row|
      elec[label("intermediate_output", row)] = [r("intermediate_output_f#{row}")]
    end
    pathway['electricity_percapita'] = elec
  end

  def population
    pop = {}
    (412..419).each do |row|
      pop[label("intermediate_output", row)] = [r("intermediate_output_e#{row}")]
    end
    pathway['population'] = pop
  end

   def energy_diversity
    d = {}
    #total_2007 = r("intermediate_output_f296").to_f
    total_2007 = r("intermediate_output_ay261").to_f
    #total_2050 = r("intermediate_output_bh296").to_f
    total_2047 = r("intermediate_output_bh261").to_f
    #(283..295).each do |row|
    #(308..320).each do |row|
    (248..260).each do |row|
      d[r("intermediate_output_d#{row}")] = { 
        '2007' => "#{((r("intermediate_output_ay#{row}").to_f / total_2007)*100).round}%",
        '2047' => "#{((r("intermediate_output_bh#{row}").to_f / total_2047)*100).round}%"
      }
    end
    pathway['diversity'] = d
  end

  def dependencies
    dep = {}
    (65..72).each do |row|
      dep[label("intermediate_output", row)] = annual_data("intermediate_output", row)
    end
    pathway['dependencies'] = dep
  end
# ADDING FUNCTION WARNING HERE
  def warning
    warn = {}
    warn['50_percent_chance_warming'] = 'WARNING: Cumulative CO2 emissions by 2100 exceed 3010 GtCO2, the amount associated with a 50% chance of keeping global mean temperature increase below 2C by 2100. Reduce emissions by increasing effort across more levers.'
    warn['bio_oversupply'] = 'No warning on bio crop oversupply'
    warn['electricity_oversupply'] = 'electricity_oversupply'
    warn['coal_reserves'] = 'No warning on coal consumption'
    warn['forest'] = 'No warning on forest area change'
    warn['fossil_fuel_proportion'] = 'WARNING - your pathway increases the dependence on fossil fuels from 2011 to 2050. A greater dependence of on fossil fuels in the global primary energy supply mix could mean greater import dependence for some countries and greater exposure to possibly volatile fossil fuel prices. Click on energy tab to view fossil fuel dependence.'
    warn['gas_reserves'] = 'No warning on gas consumption'
    warn['land_use'] = 'No warning on land use'
    warn['oil_reserves'] = 'No warning on oil consumption'

    pathway['warning'] = warn
  end

  def energy_share
    share = {}
    (25..30).each do |row|
      share[label("charts", row)] = annual_data("charts", row)
    end
    pathway['energy_share'] = share
  end
  
  def emissions_do_nothing
    t = {}
    (164..171).each do |row|
      t[label("charts", row)] = [r("charts_ay#{row}"),r("charts_ba#{row}"),r("charts_bb#{row}")]
    end
    pathway['emissions_do_nothing'] = t
  end
  
  # Helper methods
  
  def table(start_row,end_row)
    t = {}
    (start_row..end_row).each do |row|
      t[label("intermediate_output", row)] = annual_data("intermediate_output",row)
    end
    t
  end
  
  def label(sheet,row)
    r("#{sheet}_d#{row}").to_s
  end
  
  def annual_data(sheet,row)
    ['ba','bb','bc','bd','be','bf','bg','bh'
    ].map { |c| r("#{sheet}_#{c}#{row}") }
  end
  
  def sum(hash_a,hash_b)
    return nil unless hash_a && hash_b
    summed_hash = {}
    hash_a.each do |key,value|
      summed_hash[key] = value + hash_b[key]
    end
    return summed_hash
  end
  
end

if __FILE__ == $0
  g = ModelResult.new

  tests = 100
  t = Time.now
  a = []
  tests.times do
    a << g.calculate_pathway(ModelResult::CONTROL.map { rand(4)+1 }.join)
  end
  te = Time.now - t
  puts "#{te/tests} seconds per run"
  puts "#{tests/te} runs per second"
end
