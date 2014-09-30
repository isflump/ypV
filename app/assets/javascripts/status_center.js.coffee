# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

sessionStatus = null
sessionTags = null
$(document).ready ->
  if $('body').find('.doomtrain').length > 0
    $.ajax({
          type: "POST",
          url: "all",
          data: ''
          success:(data) ->
            console.log(data)
            if data['sessions'].length > 0
              date = new Date(data['sessions'][0].pass_rate)
              #dataPassStartPoint = Date.UTC(date.getUTCFullYear(), date.getUTCMonth(), date.getUTCDate())
              sessionStatus = data['sessions']
              sessionTags = data['tagMap']
              filterBaseOnTag("None")
        })

@filterBaseOnTag = (tag) ->
  dataPass = []
  if tag is "None"
    title = "Pass Rate"
  else
    title = "Pass Rate with tag " + tag

  for ses in sessionStatus
    if tag is "None" or tag in sessionTags[ses.id]
      if ses.pass_rate isnt null
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
          tags: sessionTags[ses.id].join()
          marker: {
            symbol: sym
            }
          })
  construct_lineChart("#overallPassRateLine",title, dataPass)

construct_lineChart = (chartID,title,dataPass) ->
  $(chartID).highcharts({
    chart:
        zoomType: 'x'
        type: 'spline'
        width: 900
        height: 355
        backgroundColor: "transparent"
    title:
        text: title
        style: { "color": "white"}
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
