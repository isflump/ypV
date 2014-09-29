# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/
$(document).ready ->
  if $('body').find('.doomtrain').length > 0
    $.ajax({
          type: "POST",
          url: "all",
          data: ''
          success:(data) ->
            console.log(data)
            label = []
            dataPass = []
            if data['sessions'].length > 0
              date = new Date(data['sessions'][0].pass_rate)
              dataPassStartPoint = Date.UTC(date.getUTCFullYear(), date.getUTCMonth(), date.getUTCDate())

              for ses in data['sessions']
                if ses.pass_rate isnt null
                  console.log ses.id
                  if ses.pass_rate >= 95
                    sym = 'url(/assets/star.png)'
                  else if ses.pass_rate < 50
                    sym = 'url(/assets/exclamation-triangle.png)'
                  else
                    sym = 'url(/assets/cloud.png)'

                  date = new Date(ses.start_time)
                  dataPass.push({
                    x: Date.UTC(date.getUTCFullYear(),date.getUTCMonth(), date.getUTCDate(), date.getHours() , date.getUTCMinutes(), date.getUTCSeconds()),
                    y: ses.pass_rate,
                    tags: data['tagMap'][ses.id].join()
                    marker: {
                      symbol: sym
                      }
                    })
              construct_lineChart("#overallPassRateLine","Pass Rate", dataPassStartPoint, dataPass)
        })

pass_color="rgba(152, 198, 50,0.6)"

construct_lineChart = (chartID,title,dataPassStartPoint,dataPass) ->
  $(chartID).highcharts({
    chart:
        zoomType: 'x'
        type: 'spline'
        width: 900
        height: 355
        backgroundColor: "transparent"
    title:
        text: title
    xAxis:
        type: 'datetime',
        dateTimeLabelFormats:
            month: '%e. %b'
            year: '%Y'
    yAxis:
        min: 0
        max: 100
        gridLineColor: '#858585'
        title:
            text: ''
    colors: ['#aaa'],
    tooltip:
        headerFormat: '<b>{series.name}</b><br>',
        pointFormat: '{point.x:%Y %b %e %H:%M:%S}: {point.y}% with tags: {point.tags}'
    plotOptions:
      spline:
        lineWidth: 2
        # dataLabels:
        #     enabled: true
        #     color: 'white'
        #     format: '{point.y}%'
    series: [{
            name: 'Pass Rate'
            data: dataPass
            }]
  })
