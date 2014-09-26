class EnergySecurity
  titles_dependency = ['Coal Imports',
                       'Oil Imports',
			'Gas Imports',
                       'Overall Import Dependence',
  ]

  titles_import_costs = ["Coal Imports","Oil Imports","Gas Imports" ,]
  titles_import_proportion = ["Coal imports", "Oil imports", "Gas imports",


  ]
  setup: () ->
    target = $('#results')
    target.append("<div id='dependency_chart' class='chart'></div>")
    target.append("<div id='import_proportion_chart' class='chart'></div>")
    target.append("<div id='import_costs_chart' class='chart'></div>")
    #The following lines position the viewmessage box, chart and results
    document.getElementById("dependency_chart").style.width = "23%"
    document.getElementById("import_proportion_chart").style.width = "24%"
    document.getElementById("import_costs_chart").style.width = "24%"
    document.getElementById("results").style.overflow = "inherit"
    document.getElementById("viewmessage").style.width = "16%"
    document.getElementById("viewmessage").style.margin = "1% 0% 1% 1%"



    @dependency_chart = new Highcharts.Chart({
      chart: {
        renderTo: 'dependency_chart',
        type: 'line',


      },
      title: { text: 'Import Dependence' },
      subtitle: { text: "Percentage of fossil fuels imported"},
      yAxis: { title: null, min: 0, max: 100 },
      xAxis: {
        labels: formatter: ->


          switch @value
            when 2012
              return 2012

            when 2027
              return 2027
            when 2037
              return 2037
            when 2047
              return 2047

        value: (148400),
        dashStyle: 'longdashdot'
      },
      legend: {
        enabled: true,
        backgroundColor: 'rgba(0,0,0,0.1)',
        floating: true,
        align: 'right',
        verticalAlign: 'bottom',
        itemStyle: {
          font: '8pt sans-serif',
        },
        itemDistance: '5pt',
        layout: 'vertical',
        left: 20,
        labelFormatter: ->
          words = @name.split(/[\s]+/).splice(0, 2)
          numWordsPerLine = 4
          str = []
          for word of words
            str.push "<br>"  if word > 0 and word % numWordsPerLine is 0
            str.push words[word]
          str.join " "
      },
      tooltip: {
        formatter: () ->
          "<b>#{this.series.name}</b><br/>#{this.x}: #{Highcharts.numberFormat(this.y, 0, ',')} % Imported"
      },
      series: []

    })



    @import_costs_chart = new Highcharts.Chart({
      chart: { renderTo: 'import_costs_chart', type: 'column' },
      title: { text: 'Import Costs' },
      subtitle: { text: "In INR Crore (10 million) / yr"},
      yAxis: { title: null, min: 0, max: 10000000 , stackLabels: {
        enabled: false,
        style: {
          fontWeight: 'bold',
          color: (Highcharts.theme && Highcharts.theme.textColor) || 'gray'
        }
      }},

      legend: {
        enabled: true,
        backgroundColor: 'rgba(0,0,0,0.1)',
        floating: true,
        align: 'center',
        verticalAlign: 'middle',
        itemStyle: {
          font: '8pt sans-serif',
        },
        itemDistance: '5pt',
        layout: 'vertical',
        left: 20,
        labelFormatter: ->
          if @name.toLowerCase() == "energy demand in least effort scenario"
            return "Least effort"
          words = @name.split(/[\s]+/).splice(0, 6)
          numWordsPerLine = 4
          str = []
          for word of words
            str.push "<br>"  if word > 0 and word % numWordsPerLine is 0
            str.push words[word]
          str.join " "
      },


      tooltip: {
        formatter: () ->
          "<b>#{this.series.name}</b><br/>#{this.x}: #{Highcharts.numberFormat(this.y, 0, ',')} INR Crore"
      },
      plotOptions: {
        column: {
          stacking: 'normal',
          dataLabels: {
            enabled: false,
            color: (Highcharts.theme && Highcharts.theme.dataLabelsColor) || 'white'
          }
        }
      },
      series: []

    })


    @import_proportion_chart  =  new Highcharts.Chart({
      chart: {
        type: 'column',renderTo: 'import_proportion_chart' },
      title: { text: 'Oil, Gas & Coal Imports' },
      subtitle: { text: "In TWh/yr"},
      yAxis: { title: null, min: 0, max: 40000 },
      tooltip: {
        formatter: () ->
          "<b>#{this.series.name}</b><br/>#{this.x}: #{Highcharts.numberFormat(this.y, 0, ',')} TWh/yr"
      },
      plotOptions: {
        series: {
          stacking: 'normal'
        }
      },
      legend: {
        enabled: true,
        backgroundColor: 'rgba(0,0,0,0.1)',
        floating: true,
        align: 'center',
        verticalAlign: 'middle',
        itemStyle: {
          font: '8pt sans-serif',
        },
        itemDistance: '5pt',
        layout: 'vertical',
        left: 20,
        labelFormatter: ->
          if @name.toLowerCase() == "energy demand in least effort scenario"
            return "Least effort"
          words = @name.split(/[\s]+/).splice(0, 6)
          numWordsPerLine = 4
          str = []
          for word of words
            str.push "<br>"  if word > 0 and word % numWordsPerLine is 0
            str.push words[word]
          str.join " "
      },

      series: []

    })

  teardown: () ->
    $('#results').empty()
    @dependency_chart = null
    @import_costs_chart = null
    @import_proportion_chart = null

  updateResults: (@pathway) ->
    @setup() unless @dependency_chart? && @import_costs_chart? && @import_proportion_chart?

    i = 0
    for name in titles_dependency
      data = @pathway['dependency'][name]

      # data contains 0.1 for 10%, so multiply by 100 for charting
      data = ((d*100) for d in data)

      if @dependency_chart.series[i]?
        @dependency_chart.series[i].setData(data,false)
      else
        @dependency_chart.addSeries({name:name,data:data},false)
      i++


    # The fourth in the series is the total, so we want to make it blacker, thicker and more dotted
    # than the other lines
    @dependency_chart.series[3].color = "#000000"
    @dependency_chart.series[3].options.lineWidth = 3
    @dependency_chart.series[3].options.dashStyle = "longdashdot"

    i = 0
    for name in titles_import_costs
      data = @pathway['import_costs'][name]

      if @import_costs_chart.series[i]?
        @import_costs_chart.series[i].setData(data,false)
      else
          @import_costs_chart.addSeries({name:name,data:data},false)
      i++
    data = @pathway['import_costs']['Total Fuel Import Costs']
    if @import_costs_chart.series[i]?
      @import_costs_chart.series[i].setData(data,false)
    else
      @import_costs_chart.addSeries({type: 'line', name: 'Total import costs in chosen scenario',data:data, lineColor: '#000', color: '#000',lineWidth:2,dashStyle:'Dot', shadow: false},false)
    i++
    i = 0
    for name in titles_import_proportion
      data = @pathway['import_proportions'][name]
      console.log(data)
      if @import_proportion_chart.series[i]?
        @import_proportion_chart.series[i].setData(data,false)
      else
        @import_proportion_chart.addSeries({name:name,data:data},false)
      i++
    data = @pathway['import_proportions']['Overall imports']
    if @import_proportion_chart.series[i]?
      @import_proportion_chart.series[i].setData(data,false)
    else
      @import_proportion_chart.addSeries({type: 'line', name: 'Total imports in chosen scenario',data:data, lineColor: '#000', color: '#000',lineWidth:2,dashStyle:'Dot', shadow: false},false)

    @dependency_chart.redraw()
    @import_costs_chart.redraw()
    @import_proportion_chart.redraw()
    document.getElementById("viewmessage").style.display = "inline-block"

    #Text for viewmessage textbox
    document.getElementById("viewmessage").innerHTML="
                     <h3> A note on fuel import prices  </h3>
                     <p>
                         Prices for imported fossil fuels (coal, oil and gas) are based on the IEA, World Energy Outlook 2035's Current Policy scenario.  <br>
                         Fuel prices after 2035 have been maintained at 2035 levels, in the absence of any other credible projections for global prices of fossil fuel imports.
                         Additionally, the prices of LNG have been taken to be the average of the US, Eurpean and Japanese import prices. <br>
                         These prices are in real 2012 USD terms, assuming a coversion rate of 1 USD to INR 60.



                      </p>

      "


window.twentyfifty.views['energy_security'] = new EnergySecurity


