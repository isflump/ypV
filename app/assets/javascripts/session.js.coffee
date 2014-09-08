# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

sessionDataHolder=null
sessionShortHistoryMap=null

pass_color="rgba(152, 198, 50,0.6)"
fail_color="rgba(206, 43, 43,0.6)"
spira_auto_color="rgba(0, 173, 243,0.85)"
spira_manual_color="rgba(37, 37, 48,0.5)"
currentPath=null
tableOptions = {
  "pageLength": 50
  }
#holds a endPoints path name that cannot click into anymore
endPoint=[]
#holds all test case names
test_case_ids = []

$(document).ready ->
  if $('body').find('.tonberry').length > 0
    $.ajax({
          type: "POST",
          url: document.URL+"/getStatus",
          data: ''
          success:(data) ->
            console.log(data)
            sessionDataHolder=data["executions"]
            for ele  in sessionDataHolder
              test_case_ids.push ele['case_id']
            sessionShortHistoryMap=data["shortHistoryMap"]
            table=""
            for exec in sessionDataHolder
                table += construct_table(exec)
            $('#sessionTableBody').html(table)
            $("#sessionTable").dataTable(tableOptions)

            if data['error'] isnt null
              #construct_pieChart('#sessionStatusChart','Overall ratio',data["sessionStatusPass"],data["sessionStatusFail"])
              construct_combChart("#sessionFolderChart",'Overall ratio at root folder',data['sessionLocationLabel'],data['sessionLocationPass'],data['sessionLocationFail'],data["sessionStatusPass"],data["sessionStatusFail"])
            else
              console.log(data["trace"])
          error:(data) ->
            console.log(data["trace"])

            #showError('Error on request',data)
        })
    render_spira_info()


@show_spira_info = () ->
  $('body').css('overflow','hidden')
  $('#spira_full_screen_grey_layer').show( "fold", {}, 'slow' );

@render_spira_info = () ->
  $.ajax({
        type: "POST",
        url: document.URL+"/getSpiraStructure",
        data: ''
        success:(data) ->
          console.log(data)
          spira_table = []
          isSameLevelFodler=false
          status_collector = {}
          case_collector = {}
          curLevel = 0
          folder_collector ={}
          for c, index in data['spira_cases'].reverse()
            indentLevel = ''
            indentLevel = c.indentLevel.length
            indent = ''
            #add indentation based on provided indent
            for i  in [1..c.indentLevel.length / 3]
              indent += '&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;'
            curLevel = c.indentLevel.length
            #if folder
            if c.isFolder is "true"
              #get total case from the child level
              totalCase = if case_collector[(curLevel + 3)] isnt undefined then case_collector[(curLevel + 3)] else 0
              #get the automate case from the child level
              autoCase = if status_collector[(curLevel + 3)] isnt undefined then  status_collector[(curLevel + 3)] else 0
              #clear child level
              case_collector[(curLevel + 3)] = 0
              status_collector[(curLevel + 3)] = 0
              #inherit data to the current level
              if case_collector[curLevel] isnt undefined then case_collector[curLevel] += totalCase else case_collector[curLevel] = totalCase
              if status_collector[curLevel] isnt undefined then status_collector[curLevel] += autoCase else status_collector[curLevel] = autoCase
              percentage = if totalCase != 0 then parseInt(autoCase * 100 / totalCase ) else 0
              if percentage > 75
                tr_class = 'spira_td_100'
              else if percentage > 50
                tr_class = 'spira_td_75'
              else if percentage > 25
                tr_class = 'spira_td_50'
              else if percentage > 0
                tr_class = 'spira_td_25'
              else
                tr_class = 'spira_td_0'
              spira_table.push "<tr id=" + index + " onclick=collapseRows(" + index + ") data-parent='None' data-id=\"collapse\"  class=" + tr_class + " style=\"cursor:pointer;\"><td style='width:700px'>" + indent + " <i id=\"icon_" + index + "\" class=\"fa fa-folder-open-o\"></i> "  + c.name + "</td><td>"  + c.author + "</td><td>" + autoCase + " / " + totalCase + "</td><td>" + percentage + "%</td></tr>"
              #===============================build hash session========================================
              temp = {}
              if folder_collector[(curLevel + 3)] isnt undefined and folder_collector[(curLevel + 3)].length > 0
                temp[c.name] = {"automated":autoCase,"total": totalCase,"sub_folders": folder_collector[(curLevel + 3)]}
                if folder_collector[curLevel] isnt undefined then folder_collector[curLevel].push temp else folder_collector[curLevel] = [temp]
                folder_collector[(curLevel + 3)] = []
              else
                temp[c.name] = {"automated":autoCase,"total": totalCase,"sub_folders": []}
                if folder_collector[curLevel] isnt undefined then folder_collector[curLevel].push temp else folder_collector[curLevel] = [temp]
              #=========================================================================================
            #if test case
            else
              #add 1 to case collector
              if case_collector[curLevel] isnt undefined then case_collector[curLevel] += 1 else case_collector[curLevel] = 1
              # if test case has a run in the session
              if c.name in test_case_ids
                #add 1 to status collector
                if status_collector[curLevel] isnt undefined then status_collector[curLevel] += 1 else status_collector[curLevel] = 1
                spira_table.push "<tr id=" + index + " data-parent=\"None\" class=\"spira_td_100\" style=\"cursor:pointer;\"><td>" + indent + " <i class=\"fa fa-file-o\"></i> " + c.name + "</td><td>"  + c.author + "</td><td>1 / 1</td><td >100%</td></tr>"
              else
                spira_table.push "<tr id=" + index + " data-parent=\"None\" style=\"cursor:pointer; color:#777 !important\"><td>" + indent + " <i class=\"fa fa-file-o\"></i> " + c.name + "</td><td>"  + c.author + "</td><td>0 / 1</td><td class=\"spira_td_0\">0%</td></tr>"

          $("#spiraTableBody").html(spira_table.reverse().join())
          $("#spiraTable").dataTable({
            "ordering": false,
            "stripeClasses": [],
            "paging": false
            })
          #===============reserved for spira chart==============================
          category_data = []
          autoCase_data = []
          nAutoCase_data = []
          console.log folder_collector
          for f in folder_collector[3].reverse()
            category_data.push Object.keys(f)[0]
            autoCase_data.push f[Object.keys(f)[0]]["automated"]
            nAutoCase_data.push f[Object.keys(f)[0]]["total"] - f[Object.keys(f)[0]]["automated"]
          $("#spiraChart").highcharts({
              chart:
                  type: 'column'
                  width: 1000
                  height: 355
                  backgroundColor: "transparent"
              title:
                  text: 'Spira Coverage'
              xAxis:
                  categories: category_data
              yAxis:
                  min: 0,
                  title: {
                      text: ''
                  },
                  stackLabels: {
                      enabled: true,
                      style: {
                          fontWeight: 'bold',
                          color: (Highcharts.theme && Highcharts.theme.textColor) || 'gray'
                      }
                  }
              colors: [spira_manual_color, spira_auto_color]
              plotOptions:
                  column:
                      stacking: 'normal',
              series: [
                {
                    type: 'column'
                    name: 'Case Not Covered in Current Execution'
                    data: nAutoCase_data
                    borderColor: '#aaa'
                },{
                    type: 'column'
                    name: 'Case Covered in Current Execution'
                    data: autoCase_data
                    borderColor: '#aaa'
                }]
          })
        error:(data) ->
          console.log(data["trace"])
          #showError('Error on request',data)
      })

@hide_spira_info = () ->
  $('#spira_full_screen_grey_layer').hide( "fold", {}, 'slow' );
  $('body').css('overflow','auto')

@collapseRows = (id) ->
  curAction = $("#"+id).data("id")
  baseLength = $("#"+id).find("td")[0].innerHTML.match(/&nbsp;/g).length

  for row in $("#"+id).nextAll()
    if $("#"+row.id).find("td")[0].innerHTML.match(/&nbsp;/g).length > baseLength
      if curAction is 'collapse'
        if $("#"+row.id).data("parent") is "None"
          $("#"+row.id).data("parent",id)
          $("#"+row.id).hide()
      else
        if $("#"+row.id).css("display") is "none" and $("#"+row.id).data("parent") is id
          $("#"+row.id).show()
          $("#"+row.id).data("parent",'None')
    else
      break

  if curAction is 'collapse'
    $("#"+id).data("id",'expand')
    $("#icon_"+id).removeClass("fa-folder-open-o")
    $("#icon_"+id).addClass("fa-folder-o")
  else
    $("#"+id).data("id",'collapse')
    $("#icon_"+id).removeClass("fa-folder-o")
    $("#icon_"+id).addClass("fa-folder-open-o")

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
                window.open('/session/'+calEvent.id,'_blank')
                return
              ,eventMouseout: (calEvent, jsEvent, view) ->
                hide_calendar_info()
                return
            $('body').css('overflow','hidden')
            $("#spira_logo").hide()
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
  $('#full_calendar_execution_info_detail_text6').html('<font style="color:#55DAE1;font-weight:bold">Result:</font> ' )
  #fill info here
  data = {}
  data['sid'] = id
  $.ajax({
        type: "POST",
        url: document.URL+"/getSessionInfoById",
        data: data
        success:(data) ->
          console.log data
          $('#full_calendar_execution_info_detail_text2').html('<font style="color:#55DAE1;font-weight:bold">Start At:</font> ' + data['start_at'])
          $('#full_calendar_execution_info_detail_text3').html('<font style="color:#55DAE1;font-weight:bold">End At:</font> ' + data['end_at'])
          $('#full_calendar_execution_info_detail_text4').html('<font style="color:#55DAE1;font-weight:bold">OS:</font> ' + data['os'])
          $('#full_calendar_execution_info_detail_text5').html('<font style="color:#55DAE1;font-weight:bold">IP:</font> ' + data['ip'])
          $('#full_calendar_execution_info_detail_text6').html('<font style="color:#55DAE1;font-weight:bold">Result:</font> <font class="ypv_pass">' + data['result_pass'] + '</font>/<font class="ypv_fail">' + (parseInt(data['result_all']) - parseInt(data['result_pass'])) + '</font>/<font color="#ccc">' + data['result_all'] + '</font>')
          if /chrome/i.test data['device']
            $('#full_calendar_execution_info_detail_text1').attr('src' , '/assets/chrome-icon.png')
          else if /firefox|firefox_no_js/i.test data['device']
            $('#full_calendar_execution_info_detail_text1').attr('src' , '/assets/firefox-icon.png')
          else if /ie/i.test data['device']
            $('#full_calendar_execution_info_detail_text1').attr('src' , '/assets/ie-icon.png')
          else if /samsung/i.test data['device']
            $('#full_calendar_execution_info_detail_text1').attr('src' , '/assets/samsung.png')
          else if /google/i.test data['device']
            $('#full_calendar_execution_info_detail_text1').attr('src' , '/assets/nexus.png')
        error:(data) ->
          console.log(data["trace"])
          #showError('Error on request',data)
      })

  rightPos = $('#' + id).offset().left + $('#' + id).outerWidth() + 5
  topPos = $('#' + id).offset().top +  parseInt($('#' + id).css('height')) - 22.5 - parseInt($(window).scrollTop())
  $('#full_calendar_execution_info').css('top' , topPos)
  $('#full_calendar_execution_info').css('left' , rightPos)
  $('#full_calendar_execution_info').show()
@hide_calendar_info = () ->
  $('#full_calendar_execution_info').hide()
@close_full_calendar = () ->
  $('#exec_time_full_screen_grey_layer').hide()
  $('body').css('overflow','auto')
  $("#spira_logo").show()

activePoints=null
@filterBySessionStatus_hightChart = (status,evt)->
  if not activePoints or activePoints isnt status.toLowerCase()
    activePoints = status.toLowerCase()
    table=""

    for exec in sessionDataHolder
      if exec.result is activePoints
        if currentPath is null
          table += construct_table(exec)
        else
          if exec.location.indexOf(currentPath) >= 0
            table += construct_table(exec)

    $('#sessionTable').DataTable().destroy()
    $('#sessionTableBody').html(table)
    $('#sessionTable').DataTable(tableOptions)
  else
    table=""
    for exec in sessionDataHolder
      if currentPath is null
        table += construct_table(exec)
      else
        if exec.location.indexOf(currentPath) >= 0
          table += construct_table(exec)

    $('#sessionTable').DataTable().destroy()
    $('#sessionTableBody').html(table)
    $('#sessionTable').DataTable(tableOptions)
    activePoints = null

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

  if ($('#' + id).offset().top + parseInt($('#' + display_id).css('height'))) >  $(window).height()
    topPos = $('#' + id).offset().top -  parseInt($('#' + display_id).css('height')) + 21.5 - parseInt($(window).scrollTop())
    if $('#' + display_id).hasClass('detail_exec_time_block')
      $('#' + display_id).removeClass('detail_exec_time_block')
    if !$('#' + display_id).hasClass('detail_exec_time_block_bottom')
      $('#' + display_id).addClass('detail_exec_time_block_bottom')
  else
    topPos = $('#' + id).offset().top +  parseInt($('#' + id).css('height')) - 21.5 - parseInt($(window).scrollTop())
  $('#' + display_id).css('top' , topPos)
  $('#' + display_id).css('left' , rightPos)

  $('#' + display_id).show()

@dismiss_detail_exec_time = () ->
  $('.detail_exec_time_block').hide()
  $('.detail_exec_time_block_bottom').hide()

@filterBySessionLocation_highchart = (chart,isForward,removePath) ->
  table=""
  obj={}
  labels=[]
  status=[]
  passed=[]
  failed=[]
  isTopLevel=null

  if isForward
    path=chart.category
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
        l = tempLoc.replace(/^test_/,"")

        if exec.result is 'passed'
          obj[tempLoc]={passed : 1,failed : 0}
        else
          obj[tempLoc]={passed : 0,failed : 1}

      table += construct_table(exec)
  #end of for loop

  if isForward
    if isTopLevel
      $("#session_path_tag").append('<div class="path_tag" onclick="filterBySessionLocation_highchart(this,false,\''+currentPath.replace("\\"+path,"").replace("\\","_YPVREP_")+'\')" onmouseover="highlight_path_tag(this)" onmouseout="lowlight_path_tag(this)">'+ icon + ' ' + path + '</div>')
    else
      $("#session_path_tag").append('<div class="path_tag" onclick="filterBySessionLocation_highchart(this,false,null)" onmouseover="highlight_path_tag(this)" onmouseout="lowlight_path_tag(this)">'+ icon + ' '+path+'</div>')
    title = 'Result at path ' + currentPath
  else
    tempCurrentPath=null
    if currentPath
      for p in currentPath.split("\\")
        if tempCurrentPath
          $("#session_path_tag").append('<div class="path_tag" onclick="filterBySessionLocation_highchart(this,false,\''+tempCurrentPath+'\')" onmouseover="highlight_path_tag(this)" onmouseout="lowlight_path_tag(this)"'+ icon + ' '+p+'</div>')
          tempCurrentPath += "_YPVREP_" + p
        else
          $("#session_path_tag").html('<div class="path_tag" onclick="filterBySessionLocation_highchart(this,false,null)" onmouseover="highlight_path_tag(this)" onmouseout="lowlight_path_tag(this)">'+ icon + ' '+p+'</div>')
          tempCurrentPath = p
      title = 'Result at path ' + currentPath
    else
      $("#session_path_tag").html("")
      title = 'Overall result at root folder'

  for l in labels
    passed.push(obj[l].passed)
    failed.push(obj[l].failed)

  passSum = passed.reduce((a, b) ->
    a + b)
  failSum = failed.reduce((a, b) ->
    a + b)

  # construct_pieChart('#sessionStatusChart', title_pie ,passSum,failSum)
  construct_combChart("#sessionFolderChart",title,labels,passed,failed,passSum,failSum)
  $('#sessionTable').DataTable().destroy()
  $('#sessionTableBody').html(table)
  $('#sessionTable').DataTable(tableOptions)

pre_hightLight=null
pre_hightLightColor=null
@highlight_session_row = (id) ->
  return if pre_hightLight is id
  temp_color = $("#"+id).css("color")
  $("#"+id).css("color","#FFF200")
  for i in [0...5]
    if $("#"+id+"_trace_"+i)
      $("#"+id+"_trace_"+i).addClass("active")

  if pre_hightLight
    $("#"+pre_hightLight).css("color",pre_hightLightColor)
    for i in [0...5]
      if $("#"+pre_hightLight+"_trace_"+i)
        $("#"+pre_hightLight+"_trace_"+i).removeClass("active")

  pre_hightLightColor = temp_color
  pre_hightLight = id

@navigate_to_execution = (row_id,execution_id,isViewed) ->
  window.open('/execution/' + execution_id,'_blank')
  if not isViewed
    $("#"+row_id).css('color','#666')
    pre_hightLightColor = $("#"+row_id).css("color")

# construct_pieChart = (chartID, title, dataPass,dataFail) ->
#   $(chartID).highcharts({
#       chart:
#           plotShadow: false
#           width: 350
#           height: 355
#           backgroundColor: "transparent"
#           style:
#             fontFamily: 'monospace'
#             color:"#aaa"
#       colors: [pass_color, fail_color]
#       title:
#           text: title
#       tooltip:
#           pointFormat: '{point.percentage:.0f}%</b>'
#       plotOptions:
#           pie:
#               allowPointSelect: true,
#               cursor: 'pointer',
#               dataLabels:
#                 enabled: false
#               showInLegend: true
#
#       series: [{
#           type: 'pie'
#           name: 'Pass/Fail Ratio'
#           data: [
#               ['Passed',   dataPass],
#               ['Failed',   dataFail]
#           ]
#           point:
#             events:
#               click: (event) ->
#                 filterBySessionStatus_hightChart(this,event)
#       }]
#     })
construct_combChart = (chartID,title,label,dataPass,dataFail,dataPiePass,dataPieFail) ->
  $(chartID).highcharts({
    chart:
        type: 'column'
        width: 900
        height: 355
        backgroundColor: "transparent"
    title:
        text: title
    xAxis:
        categories: label
        labels:
          formatter: () ->
              text = this.value
              if text.replace(/^test_/,"").length > 15
                formatted = text.replace(/^test_/,"").substring(0, 15) + '...'
              else
                formatted = text.replace(/^test_/,"")
              return '<div class="js-ellipse" style="overflow:hidden" title="' + text + '">' + formatted + '</div>';
          useHTML: true
    yAxis:
        min: 0,
        title: {
            text: ''
        },
        stackLabels: {
            enabled: true,
            style: {
                fontWeight: 'bold',
                color: (Highcharts.theme && Highcharts.theme.textColor) || 'gray'
            }
        }
    colors: [pass_color, fail_color]
    plotOptions:
        pie:
            allowPointSelect: true,
            cursor: 'pointer',
            dataLabels:
              enabled: false
        column:
            stacking: 'normal',
            point:
              events:
                click: (evt) ->
                  filterBySessionLocation_highchart(this,true,'NONE')
            events:
              legendItemClick: () ->
                if this.name is 'Passed'
                  filterBySessionStatus_hightChart('Failed',event)
                else
                  filterBySessionStatus_hightChart('Passed',event)
    series: [{
        type: 'column'
        name: 'Passed'
        data: dataPass
    }, {
        type: 'column'
        name: 'Failed'
        data: dataFail
    }, {
        type: 'pie'
        name: 'Pass/Fail Ratio'
        data: [{
            name: 'Passed'
            y: dataPiePass
        }, {
            name: 'Failed'
            y: dataPieFail
        }]
        center: [800, 30]
        size: 80
    }]
  })

construct_table = (exec) ->
  temp = ""
  if exec.isViewed
    temp = temp + '<tr id="ses_' + exec.id + '" style="cursor:pointer;color:#666" onclick="highlight_session_row(this.id)"  ondblclick="navigate_to_execution(this.id,\''+exec.id+'\',true)">'
  else
    temp = temp + '<tr id="ses_' + exec.id + '" style="cursor:pointer" onclick="highlight_session_row(this.id)"  ondblclick="navigate_to_execution(this.id,\''+exec.id+'\',false)">'

  temp = temp + '<td>' + exec.case_id + '</td>'
  temp = temp + '<td rel="tooltip" title="'+exec.location+'">' + exec.case_name + '</td>'
  temp = temp + '<td>' + Math.round(exec.duration) + '</td>'
  temp = temp + '<td>' + exec.spira_case_id + '</td>'

  temp = temp + '<td  style="text-align:center">'
  if sessionShortHistoryMap
    if sessionShortHistoryMap[exec.id] isnt null
      if sessionShortHistoryMap[exec.id].length isnt 0
        for his , i in sessionShortHistoryMap[exec.id]
          if his.result is "passed"
            temp = temp + '<i id="ses_' + exec.id + '_trace_' + i + '" rel="tooltip" title="' + his.created_at + '" class="fa fa-check-circle sessionTablePassHistoryTrace"></i> '
          else
            temp = temp + '<i id="ses_' + exec.id + '_trace_' + i + '" rel="tooltip" title="' + his.created_at + '" class="fa fa-bug sessionTableFailHistoryTrace"></i> '

  temp = temp + '</td>'

  if exec.result is "passed"
    temp = temp + '<td style="color:' + pass_color + '">'+ exec.result.toUpperCase() + '</td>'
  else if exec.result is "failed"
    temp = temp + '<td style="color:' + fail_color + '">'+ exec.result.toUpperCase() + '</td>'
  else
    temp = temp + '<td style="color:' + fail_color + '">ERROR</td>'
  temp = temp + '</tr>'
  return temp
