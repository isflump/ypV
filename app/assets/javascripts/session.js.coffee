# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/
pie_options =
{
    segmentShowStroke : true,
    segmentStrokeColor : "#1D2328",
    segmentStrokeWidth : 4,
    animationSteps : 50,
    animationEasing : "easeOutQuart",
}
bar_options = {
  bezierCurve : false,
  scaleGridLineColor : "#444",
  scaleGridLineWidth : 1,
  scaleLineColor: "rgba(240,240,240,1)",
  scaleFontColor: "#aaa"
  }

sessionDataHolder=null
pieChart=null
barChart=null
pass_color="rgba(70, 191, 189,0.5)"
red_color="rgba(247, 70, 74,0.5)"

currentPath=null
#holds a endPoints path name that cannot click into anymore
endPoint=[]
$(document).ready ->
  if $('body').find('.tonberry').length > 0
    $.ajax({
          type: "POST",
          url: document.URL+"/getStatus",
          data: ''
          success:(data) ->
            console.log(data)
            sessionDataHolder=data["executions"]


            if data['error'] isnt null
              pieData = [
                {
                    value:data["sessionStatusFail"],
                    color:red_color,
                    highlight: "#FF5A5E",
                    label: "failed",
                    title: "Failed"

                },
                {
                    value: data["sessionStatusPass"],
                    color: pass_color,
                    highlight: "#5AD3D1",
                    label: "passed",
                    title: "Passed"
                }
              ]

              pie = document.getElementById("sessionStatusChart").getContext("2d")
              pieChart = new Chart(pie).Pie(pieData,pie_options)
              legend(document.getElementById("sessionStatusLegend"), pieData)

              console.log(pieChart)
              barData = {
                labels: data['sessionLocationLabel'],
                datasets: [
                    {
                        label: "passed",
                        title: 'Passed'
                        fillColor: pass_color,
                        strokeColor: pass_color,
                        highlightFill: "rgba(70, 191, 189,0.75)",
                        highlightStroke: "rgba(70, 191, 189,1)",
                        data: data['sessionLocationPass']
                    },
                    {
                        label: "failed",
                        title: 'Failed'
                        fillColor: red_color,
                        strokeColor: red_color,
                        highlightFill: "rgba(247, 70, 74,0.75)",
                        highlightStroke: "rgba(247, 70, 74,1)",
                        data: data['sessionLocationFail']
                    }
                ]
                }

              bar = document.getElementById("sessionFolderChart").getContext("2d")
              barChart = new Chart(bar).Bar(barData,bar_options)

            else
              console.log(data["trace"])
          error:(data) ->
            console.log(data["trace"])

            #showError('Error on request',data)
        })
    $("#sessionTable").dataTable()

@show_full_calendar = () ->
  fullSessions = []
  $.ajax({
        type: "POST",
        url: document.URL+"/getAllSessions",
        data: ''
        success:(data) ->
          console.log(data)
          if data['error'] isnt null
            temp_url_ary = $(location).attr('href').split('/')
            current_id = temp_url_ary[temp_url_ary.length-1]
            console.log current_id
            for ses in data["sessions"]
              if String(ses.id) == String(current_id)
                fullSessions.push({
                  title: "1"
                  start: ses.start_time
                  end: ses.end_time
                  id: ses.id
                  class: 'whitePulse'
                  })
              else
                fullSessions.push({
                  title: "1"
                  start: ses.start_time
                  end: ses.end_time
                  id: ses.id
                  })
            $('#exec_time_full_screen_grey_layer').show()
            if !($(".fc-header").length > 0)
              $("#full_calendar").fullCalendar events: fullSessions, eventMouseover: (calEvent, jsEvent, view) ->
                show_calendar_info(calEvent.title,calEvent.id)
                return
              ,eventClick: (calEvent, jsEvent, view) ->
                console.log "here"
                return
              ,eventMouseout: (calEvent, jsEvent, view) ->
                hide_calendar_info()
                return
            $('body').css('overflow','hidden')
          else
            console.log(data["trace"])
        error:(data) ->
          console.log(data["trace"])
          #showError('Error on request',data)
      })
@show_calendar_info = (title,id) ->
  $('#full_calendar_execution_info_detail_text1').attr('src' , '')
  $('#full_calendar_execution_info_detail_text2').html('<font style="color:#55DAE1;font-weight:bold">Start At:</font> ' )
  $('#full_calendar_execution_info_detail_text3').html('<font style="color:#55DAE1;font-weight:bold">End At:</font> ')
  $('#full_calendar_execution_info_detail_text4').html('<font style="color:#55DAE1;font-weight:bold">OS:</font> ')
  $('#full_calendar_execution_info_detail_text5').html('<font style="color:#55DAE1;font-weight:bold">IP:</font> ' )
  #fill info here
  data = {}
  data['sid'] = id
  $.ajax({
        type: "POST",
        url: document.URL+"/getSessionInfoById",
        data: data
        success:(data) ->
          $('#full_calendar_execution_info_detail_text2').html('<font style="color:#55DAE1;font-weight:bold">Start At:</font> ' + data['start_at'])
          $('#full_calendar_execution_info_detail_text3').html('<font style="color:#55DAE1;font-weight:bold">End At:</font> ' + data['end_at'])
          $('#full_calendar_execution_info_detail_text4').html('<font style="color:#55DAE1;font-weight:bold">OS:</font> ' + data['os'])
          $('#full_calendar_execution_info_detail_text5').html('<font style="color:#55DAE1;font-weight:bold">IP:</font> ' + data['ip'])
          console.log data['device']
          if /chrome/i.test data['device']
            $('#full_calendar_execution_info_detail_text1').attr('src' , '/assets/chrome-icon.png')
          else if /firefox|firefox_no_js/i.test data['device']
            $('#full_calendar_execution_info_detail_text1').attr('src' , '/assets/firefox-icon.png')
          else if /ie/i.test data['device']
            $('#full_calendar_execution_info_detail_text1').attr('src' , '/assets/ie-icon.png')
          else if /android/i.test data['device']
            $('#full_calendar_execution_info_detail_text1').attr('src' , '/assets/Android-icon.png')
        error:(data) ->
          console.log(data["trace"])
          #showError('Error on request',data)
      })

  rightPos = $('#' + id).offset().left + $('#' + id).outerWidth() + 5
  topPos = $('#' + id).offset().top +  parseInt($('#' + id).css('height')) - 22.5
  $('#full_calendar_execution_info').css('top' , topPos)
  $('#full_calendar_execution_info').css('left' , rightPos)
  $('#full_calendar_execution_info').show()
@hide_calendar_info = () ->
  $('#full_calendar_execution_info').hide()

@close_full_calendar = () ->
  $('#exec_time_full_screen_grey_layer').hide()
  $('body').css('overflow','auto')
@filterBySessionStatus = (evt) ->
  activePoints = pieChart.getSegmentsAtEvent(evt)
  table=""

  for exec in sessionDataHolder
    if exec.result is activePoints[0].label
      if currentPath is null
        table += construct_table(exec)
      else
        if exec.location.indexOf(currentPath) >= 0
          table += construct_table(exec)

  $('#sessionTable').DataTable().destroy()
  $('#sessionTableBody').html(table)
  $('#sessionTable').DataTable()

  #=================================================================================
  if /pass/i.test(activePoints[0].label.toUpperCase())
    $('#session_status_tag_view').html('<div id="session_status_tag" class="pass_fail_tag_container" onclick="removeSessionStatusFilter()">' + activePoints[0].label.toUpperCase() + '</div>')
    # $('#session_table_tag_view').html('<div id="session_status_tag" class="pass_fail_tag_container" onclick="removeSessionStatusFilter()">' + activePoints[0].label.toUpperCase() + '</div>')
  else
    $('#session_status_tag_view').html('<div id="session_status_tag" class="pass_fail_tag_container fail" onclick="removeSessionStatusFilter()">' + activePoints[0].label.toUpperCase() + '</div>')
    # $('#session_table_tag_view').html('<div id="session_status_tag" class="pass_fail_tag_container fail" onclick="removeSessionStatusFilter()">' + activePoints[0].label.toUpperCase() + '</div>')
  $('#session_status_tag').width($('#session_status_tag').width())
  $('#session_status_tag').show("drop", { direction: "right" },600)

@removeSessionStatusFilter = () ->
  table=""
  for exec in sessionDataHolder
    if currentPath is null
      table += construct_table(exec)
    else
      if exec.location.indexOf(currentPath) >= 0
        table += construct_table(exec)

  $('#sessionTable').DataTable().destroy()
  $('#sessionTableBody').html(table)
  $('#sessionTable').DataTable()

  $('#session_status_tag_view').html("")

@highlight_path_tag = (tag) ->
  path_tag = $(tag)
  while path_tag.length > 0
    path_tag.addClass('active')
    path_tag = path_tag.next()
@lowlight_path_tag = (tag) ->
  path_tag = $(tag)
  while path_tag.length > 0
    path_tag.removeClass('active')
    path_tag = path_tag.next()
@show_detail_exec_time = (id,display_id) ->
  dismiss_detail_exec_time()
  rightPos = $('#' + id).offset().left + $('#' + id).outerWidth() + 5
  topPos = $('#' + id).offset().top +  parseInt($('#' + id).css('height')) - 21.5
  $('#' + display_id).css('top' , topPos)
  $('#' + display_id).css('left' , rightPos)

  $('#' + display_id).show()
  console.log "here"
@dismiss_detail_exec_time = () ->
  $('.detail_exec_time_block').hide()

@filterBySessionLocation = (evt,isForward,removePath) ->
  table=""
  obj={}
  labels=[]
  passed=[]
  failed=[]
  isTopLevel=null
  statusFilter = $('#session_status_tag').text()

  if isForward
    path=barChart.getBarsAtEvent(evt)[0].label
    if endPoint.indexOf(currentPath + "\\" + path) isnt -1
      return
    if currentPath
      currentPath += "\\" + path
      isTopLevel=true
    else
      currentPath = path
      isTopLevel=null
  else
    path = null
    currentPath = null
    if removePath
      path = removePath.replace("_YPVREP_","\\")
      currentPath = removePath.replace("_YPVREP_","\\")

  #Start of for loop
  for exec in sessionDataHolder
    isInclude=false
    if currentPath
      if exec.location.indexOf(currentPath) >= 0
        isInclude = true
        if /py$/.test(currentPath)
          icon="<i class=\"fa fa-file-text-o\"></i>"
          tempLoc = exec.case_name
          endPoint.push(currentPath+'\\'+exec.case_name)
        else
          icon="<i class=\"fa fa-folder-open-o\"></i>"
          removeParent = exec.location.replace(currentPath+'\\', "")
          tempLoc=removeParent.split("\\")[0]
    else
      tempLoc=exec.location.split("\\")[0]
      isInclude = true

    #start include the records for table construction
    if isInclude
      if obj[tempLoc]
        if exec.result is 'passed'
          obj[tempLoc].passed += 1
        else
          obj[tempLoc].failed += 1
      else
        labels.push(tempLoc)
        if exec.result is 'passed'
          obj[tempLoc]={passed : 1,failed : 0}
        else
          obj[tempLoc]={passed : 0,failed : 1}

      if statusFilter.length isnt 0
        if exec.result is statusFilter.toLowerCase()
          table += construct_table(exec)
      else
        table += construct_table(exec)
  #end of for loop

  if isForward
    if isTopLevel
      $("#session_path_tag").append('<div class="path_tag" onclick="filterBySessionLocation(this,false,\''+currentPath.replace("\\"+path,"").replace("\\","_YPVREP_")+'\')" onmouseover="highlight_path_tag(this)" onmouseout="lowlight_path_tag(this)">'+ icon + ' ' + path + '</div>')
    else
      $("#session_path_tag").append('<div class="path_tag" onclick="filterBySessionLocation(this,false,null)" onmouseover="highlight_path_tag(this)" onmouseout="lowlight_path_tag(this)">'+ icon + ' '+path+'</div>')
  else
    tempCurrentPath=null
    if currentPath
      for p in currentPath.split("\\")
        if tempCurrentPath
          $("#session_path_tag").append('<div class="path_tag" onclick="filterBySessionLocation(this,false,\''+tempCurrentPath+'\')" onmouseover="highlight_path_tag(this)" onmouseout="lowlight_path_tag(this)"'+ icon + ' '+p+'</div>')
          tempCurrentPath += "_YPVREP_" + p
        else
          $("#session_path_tag").html('<div class="path_tag" onclick="filterBySessionLocation(this,false,null)" onmouseover="highlight_path_tag(this)" onmouseout="lowlight_path_tag(this)">'+ icon + ' '+p+'</div>')
          tempCurrentPath = p
    else
      $("#session_path_tag").html("")

  for l in labels
    passed.push(obj[l].passed)
    failed.push(obj[l].failed)

  passSum = passed.reduce((a, b) ->
    a + b)
  failSum = failed.reduce((a, b) ->
    a + b)

  updatePieData = [
    {
        value:failSum,
        color:red_color,
        highlight: "#FF5A5E",
        label: "failed",
        title: "Failed"

    },
    {
        value: passSum,
        color: pass_color,
        highlight: "#5AD3D1",
        label: "passed",
        title: "Passed"
    }
  ]

  updateBarData = {
    labels: labels,
    datasets: [
        {
            label: "passed",
            title: 'Passed'
            fillColor: pass_color,
            strokeColor: pass_color,
            highlightFill: "rgba(70, 191, 189,0.75)",
            highlightStroke: "rgba(70, 191, 189,1)",
            data: passed
        },
        {
            label: "failed",
            title: 'Failed'
            fillColor: red_color,
            strokeColor: red_color,
            highlightFill: "rgba(247, 70, 74,0.75)",
            highlightStroke: "rgba(247, 70, 74,1)",
            data: failed
        }
    ]
    }
  $("#sessionGraph").html("<canvas id=\"sessionStatusChart\" height=\"255px\" width=\"350px\" onclick=\"filterBySessionStatus(event)\"></canvas><canvas id=\"sessionFolderChart\" height=\"255px\" width=\"550px\"
  onclick=\"filterBySessionLocation(event,true,'')\"></canvas><div id=\"sessionStatusLegend\" style=\"width:850px\"></div>")

  pie = document.getElementById("sessionStatusChart").getContext("2d")
  pieChart = new Chart(pie).Pie(updatePieData,pie_options)
  bar = document.getElementById("sessionFolderChart").getContext("2d")
  barChart = new Chart(bar).Bar(updateBarData,bar_options)
  legend(document.getElementById("sessionStatusLegend"), updatePieData)

  $('#sessionTable').DataTable().destroy()
  $('#sessionTableBody').html(table)
  $('#sessionTable').DataTable()

pre_hightLight=null
@highlight_session_row = (id) ->
  return if pre_hightLight is id
  $("#"+id).css("color","#FFF200")
  if pre_hightLight
    $("#"+pre_hightLight).css("color","#aaa")
  pre_hightLight = id

construct_table = (exec) ->
  temp = ""
  temp = temp + '<tr id="ses_' + exec.id + '" rel="tooltip" title="Double click to see execution detail" style="cursor:pointer" onclick="highlight_session_row(this.id)"  ondblclick="window.open(\'/execution/'+exec.id+'\',\'_blank\')">'
  temp = temp + '<td>' + exec.case_id + '</td>'
  temp = temp + '<td rel="tooltip" title="'+exec.location+'">' + exec.case_name + '</td>'
  temp = temp + '<td>' + Math.round(exec.duration) + '</td>'
  temp = temp + '<td>' + exec.spira_case_id + '</td>'
  if exec.result is "passed"
    temp = temp + '<td style="color:rgba(70, 191, 189,0.5)">'+ exec.result + '</td>'
  else
    temp = temp + '<td style="color:rgba(247, 70, 74,0.9)">'+ exec.result + '</td>'
  #temp = temp + '<td style="text-align:center" rel="tooltip" title="'+exec.location+'"><i class="fa fa-folder-o"></i></td>'
  temp = temp + '</tr>'
  return temp
