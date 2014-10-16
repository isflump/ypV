# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

sessionStatus = null
sessionTags = null
$(document).ready ->
  console.log $("#proejct_name").data('id')
  if $('body').find('.doomtrain').length > 0
    $.ajax({
          type: "POST",
          url: "all",
          data: {'project_id' : $("#project_id").data('id')}
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
@evamouseOnFirstTimeSettingButton = (id) ->
  $("#" + id).find(".eva_copy").addClass("active")
  $("#" + id).addClass("hover")
  $("#" + id).css("color", "#999")


@evamouseOutFirstTimeSettingButton = (id) ->
  $("#" + id).find(".eva_copy").removeClass("active")
  $("#" + id).removeClass("hover")
  $("#" + id).css("color", "#555")

@evaGraphConfig = (id) ->
  $('#' + id).addClass("active")
  $('#' + id).removeAttr('onmouseout');
  $('#' + id).removeAttr('onmouseover')
  evamouseOnFirstTimeSettingButton()
  if id == "evaLargeGraph1"
    $("#drawer_lt").show('slide', {direction: 'right'}, 525)


construct_lineChart = (chartID,title,dataPass) ->
  $(chartID).highcharts({
    chart:
        zoomType: 'x'
        type: 'line'
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
      line:
        lineWidth: 2
    series: [{
            name: 'Pass Rate'
            data: dataPass
            }]
  })
