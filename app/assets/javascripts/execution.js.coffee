# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/
pass_color="rgba(152, 198, 50,0.6)"
pass_hightlight="rgba(126, 178, 109,0.9)"
fail_color="rgba(206, 43, 43,0.6)"
fail_hightlight="#df6666"
pytestCurrentCase = null
pytestSelectedCase = null
$(document).ready ->
  if $('body').find('.odin').length > 0
    console.log(document.URL)
    $.ajax({
        type: "POST",
        url: document.URL+"/getHistoryTrend",
        data: ''
        success:(data) ->
          console.log(data)
          if data['error'] isnt null
            options = {
              bezierCurve : false,
              scaleGridLineColor : "#444",
              scaleGridLineWidth : 1,
              scaleLineColor: "rgba(240,240,240,1)",
              scaleFontColor: "#aaa"
              }
            line = {
              labels: data['label'],
              datasets: [
                  {
                      title: "Accumulated"
                      label: "Accumulated",
                      fillColor: "rgba(220,220,220,0.2)",
                      strokeColor: "rgba(220,220,220,1)",
                      pointColor: "rgba(220,220,220,1)",
                      pointStrokeColor: "#fff",
                      pointHighlightFill: "#fff",
                      pointHighlightStroke: "rgba(240,240,240,1)",
                      data: data['executionNumber']
                  },
                  {
                      label: "Passed",
                      fillColor: pass_color,
                      strokeColor: pass_color,
                      pointColor: pass_color,
                      pointStrokeColor: "#fff",
                      pointHighlightFill: "#fff",
                      pointHighlightStroke: pass_color,
                      data: data['executionPassNumber'],
                      title: "Passed"
                  }
              ]
              }
            ctx = document.getElementById("executionHistoryChart").getContext("2d")
            new Chart(ctx).Line(line,options)
            legend(document.getElementById("executionHistoryLegend"), line)

            bar = {
              labels: data['lastExecutionLabel'],
              datasets: [
                  {
                      label: "pass",
                      title: 'Passed'
                      fillColor: pass_color,
                      strokeColor: pass_color,
                      highlightFill: pass_hightlight,
                      highlightStroke: pass_hightlight,
                      data: data['lastExecutionPass']
                  },
                  {
                      label: "My Second dataset",
                      title: 'Failed'
                      fillColor: fail_color,
                      strokeColor: fail_color,
                      highlightFill: fail_hightlight,
                      highlightStroke: fail_hightlight,
                      data: data['lastExecutionFail']
                  }
              ]
              }

            ctx2 = document.getElementById("latestExecutionChart").getContext("2d")
            new Chart(ctx2).Bar(bar,options)
            legend(document.getElementById("latestExecutionLegend"), bar)

          else
            console.log("Error")
        error:(data) ->
          showError('Error on request',data)
      })

    $.ajax({
				type: "POST",
				url: document.URL+"/getSpira",
				data: ''
				success:(data) ->
          console.log(data)
          if data['foundCase'] is false
            $("#spiralog").html("<div class=\"spira_description\" >
              <font style=\"font-size:17px; font-weight:bold;color:#ddd\">Cannot find Spira case corespond to this test:</font>
              </div>")
          else
            content = "<div class=\"spira_description\" style=\"margin-bottom:10px;margin-top:5px\">
                  <font style=\"font-size:17px; font-weight:bold;color:#ddd\">Name:</font> "+data['tcName']+"</font>  <i style=\"color:white;cursor:pointer\" class=\"fa fa-external-link\" onclick=\"window.open('" + data['tcLink'] + "','_blank')\"></i>
                  </div>"
            if data['tcDescription'].strip is not "No Description found"
              content += "<div class=\"spira_description\"><font style=\"font-size:17px; font-weight:bold;color:#ddd\">Description:</font><br><pre>"+data['tcDescription']+"</pre></font></div>"
            content += "
                  <table class=\"spira_step_table\">
                    <tr>
                      <th>Step#</th>
                      <th> Description </th>
                      <th> Expected Result </th>
                      <th> Sample Data </th>
                    </tr>
                    <tbody>"
            if data['tcSteps']
              for step  , i in data['tcSteps']
                content += "<tr>
                            <td>Step "+(i+1)+"</td>
                            <td>" + step.tsDescription + "</td>
                            <td>" + step.tsExpectedResult + "</td>
                            <td>" + step.tsSample + "</td>
                            </tr>"
            else
              content += "<tr><td>No Steps found</td></tr>"
            content += "</tbody></table>"
            $("#spiralog").html(content)
            $("#compare_execution_spira").html(content)
				error:(data) ->
					showError('Error on request',data)
     })

    if document.getElementById('compare_current_code')
      pytestCurrentCase = CodeMirror.fromTextArea(document.getElementById('compare_current_code'), {
        lineNumbers: true,
        mode: "text/x-cython",
        theme: 'monokai',
        readOnly: true
      });

    if document.getElementById('code')
      pytestCase = CodeMirror.fromTextArea(document.getElementById('code'), {
        lineNumbers: true,
        mode: "text/x-cython",
        theme: 'monokai',
        readOnly: true
      });


@legend = (parent, data) ->
  parent.className = "legend"
  datas = (if data.hasOwnProperty("datasets") then data.datasets else data)

  # remove possible children of the parent
  parent.removeChild parent.lastChild  while parent.hasChildNodes()
  datas.forEach (d) ->
    title = document.createElement("div")
    title.className = "title"
    title.style.borderColor = (if d.hasOwnProperty("strokeColor") then d.strokeColor else d.color)
    title.style.borderStyle = "solid"
    parent.appendChild title
    text = document.createTextNode(d.title)
    title.appendChild text


@show_report_image_full_panel = () ->
  $('#background_grey_layer').show('slow')
  $('body').css('overflow','hidden')


@hide_report_image_full_panel = () ->
  $('#background_grey_layer').hide('slow')
  $('body').css('overflow','auto')

current_image_view_id = ''
go_next_id=null

@enlarge_report_image = (id) ->

  current_image_view_id = id
  go_next_id = null
  $('#report_image_large_view_box').show()
  enlarge_img_html = '<img src="' + $('#' + id).attr('src') + '" id="enlarged_img" style="border-radius:5px;border:solid 2px #aaa"></img>'
  $('#report_image_large_view_box').html(enlarge_img_html)
  if $('#enlarged_img').width() == 1080 and $('#enlarged_img').height() == 1920
    display_width = 480
  else if $(window).width() * 0.5 < $('#enlarged_img').width()
    display_width = $(window).width() * 0.5
  else
    display_width = $('#enlarged_img').width()
  $('#enlarged_img').attr('width','100%')
  $('#report_image_large_view_box').css('width',display_width)
  $('body').css('overflow','hidden')
  $('#report_image_large_view_box').css('top','50px')
  $('#report_image_large_view_box').css('left', ($(window).width() - display_width) / 2)
  $('#report_image_large_view_box').wrap('<div class="report_image_large_view_grey_layer" id="report_image_large_view_grey_layer"></div>')
  $('#report_image_large_view_grey_layer').append('<div class="report_image_large_view_max_btn" onclick="maximize_report_image()" id="report_image_large_view_max_btn"><i class="fa fa-expand"></i></div><div class="report_image_large_view_max_btn hide" onclick="reg_report_image()" id="report_image_large_view_reg_btn"><i class="fa fa-compress"></i></div> <div class="report_image_large_view_close_btn" onclick="hide_report_image_large_view()" id="report_image_large_view_close_btn"><i class="fa fa-times-circle-o"></i></div>')
  $('#report_image_large_view_grey_layer').append('<div class="report_image_next" onclick="report_image_next()" id="report_image_next"><i class="fa fa-chevron-right"></i></div>')
  $('#report_image_large_view_grey_layer').append('<div class="report_image_prev" onclick="report_image_prev()" id="report_image_prev"><i class="fa fa-chevron-left"></i></div>')
  text = {}
  imgInfoAry = $('#' + id).attr('src').split('/')
  text['img_id'] = imgInfoAry[imgInfoAry.length - 2]
  img_name = text['img_id'] = imgInfoAry[imgInfoAry.length - 1]

  $.ajax({
    type: "POST",
    url: document.URL+"/getImgName",
    data: text
    success:(data) ->
      $('#report_image_large_view_grey_layer').append('<div class="report_image_banner"><font color="#01AEF2">' + data + ': </font>' + img_name + '</div>')
    error:(data) ->
      $('#report_image_large_view_grey_layer').append('<div class="report_image_banner">Cant Load Img Info</div>')
  })


  if !$('#report_image_' + String(parseInt(current_image_view_id.split('_')[current_image_view_id.split('_').length-1]) + 1)).length > 0
    $('#report_image_next').hide()
  if parseInt(current_image_view_id.split('_')[current_image_view_id.split('_').length-1]) == 0
    $('#report_image_prev').hide()
  $('#report_image_large_view_grey_layer').show()
  $('#report_image_large_view_max_btn').removeClass('hide')


@maximize_report_image = () ->
  display_width = $(window).width() * 0.8
  $('#report_image_large_view_box').css('width',display_width)
  $('#report_image_large_view_box').css('top','0px')
  $('#report_image_large_view_box').css('left', ($(window).width() - display_width) / 2)
  $('#report_image_large_view_max_btn').addClass('hide')
  $('#report_image_large_view_reg_btn').removeClass('hide')

@reg_report_image = () ->
  if $('#enlarged_img').width() == 1920 * 0.8 && $('#enlarged_img').height() == 2731
    display_width = 480
  else if $(window).width() * 0.5 < $('#enlarged_img').width()
    display_width = $(window).width() * 0.5
  else
    display_width = $('#enlarged_img').width()
  $('#report_image_large_view_box').css('width',display_width)
  $('#report_image_large_view_box').css('top','50px')
  $('#report_image_large_view_box').css('left', ($(window).width() - display_width) / 2)
  $('#report_image_large_view_reg_btn').addClass('hide')
  $('#report_image_large_view_max_btn').removeClass('hide')

@hide_report_image_large_view = () ->
  $('#report_image_large_view_box').hide()
  $('#report_image_large_view_grey_layer').hide()
  $('#report_image_large_view_box').unwrap()
  $('#report_image_large_view_close_btn').remove()
  $('#report_image_next').remove()
  $('#report_image_prev').remove()
  $('.report_image_banner').remove()
  if !$('#report_image_large_view_max_btn').hasClass('hide')
    $('#report_image_large_view_max_btn').addClass('hide')
  if !$('#report_image_large_view_reg_btn').hasClass('hide')
    $('#report_image_large_view_reg_btn').addClass('hide')
  $('body').css('overflow','auto')


@report_image_next = () ->
  # $('#enlarged_img').hide("drop")
  # current_image_view_id_dup = current_image_view_id
  # setTimeout (->
  #   $('#enlarged_img').attr('src', $('#report_image_' + String(parseInt(current_image_view_id_dup.split('_')[current_image_view_id_dup.split('_').length-1]) + 1)).attr('src'))
  #   $('#enlarged_img').show("drop", { direction: "right" })
  #   ), 450
  # $('#report_image_prev').show()
  # if !$('#report_image_' + String(parseInt(current_image_view_id_dup.split('_')[current_image_view_id_dup.split('_').length-1]) + 2)).length > 0
  #   $('#report_image_next').hide()
  #   current_image_view_id = 'report_image_' + String(parseInt(current_image_view_id_dup.split('_')[current_image_view_id_dup.split('_').length-1]) + 1)

  $('#enlarged_img').hide("drop")
  if !go_next_id
    go_next_id=current_image_view_id

  nextSrc=$('#report_image_' + (parseInt(go_next_id.replace("report_image_","")) + 1))

  if !nextSrc.length > 0
    return

  if !$('#report_image_' + (parseInt(go_next_id.replace("report_image_","")) + 2)).length > 0
    $('#report_image_next').hide()

  go_next_id = nextSrc.attr("id")
  console.log("next "+go_next_id)
  setTimeout (->
    $('#enlarged_img').attr('src', nextSrc.attr('src'))
    $('#enlarged_img').show("drop", { direction: "right" })
    ), 450

  text = {}
  imgInfoAry = nextSrc.attr('src').split('/')
  img_name = imgInfoAry[imgInfoAry.length - 1]

  $.ajax({
    type: "POST",
    url: document.URL+"/getImgName",
    data: text
    success:(data) ->
      $('.report_image_banner').remove('')
      $('#report_image_large_view_grey_layer').append('<div class="report_image_banner"><font color="#01AEF2">' + data + ': </font>' + img_name + '</div>')
    error:(data) ->
      $('.report_image_banner').remove('')
      $('#report_image_large_view_grey_layer').append('<div class="report_image_banner">Cant Load Img Info</div>')
  })

  if $('#report_image_prev').css("display") is "none"
    $('#report_image_prev').show()

@report_image_prev = () ->
  # $('#enlarged_img').hide("drop", { direction: "right" })
  # current_image_view_id_dup = current_image_view_id
  # $('#report_image_next').show()
  # setTimeout (->
  #   $('#enlarged_img').attr('src', $('#report_image_' + String(parseInt(current_image_view_id_dup.split('_')[current_image_view_id_dup.split('_').length-1]) - 1)).attr('src'))
  #   $('#enlarged_img').show("drop")
  #   ), 450
  # if parseInt(current_image_view_id_dup.split('_')[current_image_view_id_dup.split('_').length-1]) - 1 == 0
  #   $('#report_image_prev').hide()
  #   current_image_view_id = 'report_image_' + String(parseInt(current_image_view_id_dup.split('_')[current_image_view_id_dup.split('_').length-1]) - 1)

  $('#enlarged_img').hide("drop", { direction: "right" })
  if !go_next_id
    go_next_id=current_image_view_id

  if parseInt(go_next_id.replace("report_image_","")) is 0
    return

  if (parseInt(go_next_id.replace("report_image_","")) - 1) is 0
    $('#report_image_prev').hide()

  prevSrc=$('#report_image_' + (parseInt(go_next_id.replace("report_image_","")) - 1))
  go_next_id = prevSrc.attr("id")
  console.log("prev "+go_next_id)
  setTimeout (->
    $('#enlarged_img').attr('src', prevSrc.attr('src'))
    $('#enlarged_img').show("drop")
    ), 450

  text = {}
  imgInfoAry = prevSrc.attr('src').split('/')
  img_name = imgInfoAry[imgInfoAry.length - 1]

  $.ajax({
    type: "POST",
    url: document.URL+"/getImgName",
    data: text
    success:(data) ->
      $('.report_image_banner').remove('')
      $('#report_image_large_view_grey_layer').append('<div class="report_image_banner"><font color="#01AEF2">' + data + ': </font>' + img_name + '</div>')
    error:(data) ->
      $('.report_image_banner').remove('')
      $('#report_image_large_view_grey_layer').append('<div class="report_image_banner">Cant Load Img Info</div>')
  })

  if $('#report_image_next').css("display") is "none"
    $('#report_image_next').show()

prevTabId=null
prevPanelId=null
@switch_tab_fail = (id) ->
  if prevTabId
    if prevTabId isnt id
      $("#"+prevTabId).removeClass('active')
      $("#"+id).addClass('active')
    else
      return
  else
    $("#"+id).addClass('active')
    $("#errorTab").removeClass('active')

  if id is "errorTab"
    panelId="errorlog"
  else if id is "logTab"
    panelId="userlog"
  else
    panelId="spiralog"

  $("#"+panelId).css('display','block')

  if prevPanelId
    $("#"+prevPanelId).css('display','none')
  else
    if id isnt "errorTab"
      $("#errorlog").css('display','none')

  prevTabId=id
  prevPanelId=panelId

@switch_tab_pass = (id) ->
  if prevTabId
    if prevTabId isnt id
      $("#"+prevTabId).removeClass('active')
      $("#"+id).addClass('active')
    else
      return
  else
    $("#"+id).addClass('active')
    $("#logTab").removeClass('active')

  if id is "logTab"
    panelId="userlog"
  else
    panelId="spiralog"

  $("#"+panelId).css('display','block')

  if prevPanelId
    $("#"+prevPanelId).css('display','none')
  else
    $("#userlog").css('display','none')

  prevTabId=id
  prevPanelId=panelId

@show_error_raw_log = () ->
  if $("#execution_raw_log").css("display") is "none"
    $("#execution_raw_log").css("display","block")
    $("#execution_parsed_log").css("display","none")
    $("#raw_log_icon").removeClass("fa-file-code-o")
    $("#raw_log_icon").addClass("fa-bars")
  else
    $("#execution_raw_log").css("display","none")
    $("#execution_parsed_log").css("display","block")
    $("#raw_log_icon").removeClass("fa-bars")
    $("#raw_log_icon").addClass("fa-file-code-o")


@execution_compare_with = (id) ->
  $('body').css('overflow','hidden')
  $('#compare_full_screen_grey_layer').show( "fold", {}, 'slow' );
  pytestCurrentCase.refresh()
  #$("#compare_selected_case_content").html("")
  params={}
  params['compare_id']=id
  $.ajax({
    type: "POST",
    url: document.URL+"/getCompareExecution",
    data: params
    success:(data) ->
      console.log data
      cur_title = ""
      com_title = ""
      if data['current_execution'].result is "passed"
        cur_title += "<div class=\"compare_info\"><i class=\"fa fa-smile-o\" style=\"font-size:22.5px;margin-right:5px;color:#55DAE1\"></i>" + data['current_execution'].case_name + " "
      else
        cur_title += "<div class=\"compare_info\"><i class=\"fa fa-bug\" style=\"font-size:22.5px;margin-right:5px;color:red\"></i>" + data['current_execution'].case_name + " "

      if data['compare_execution'].result is "passed"
        com_title += "<div class=\"compare_info\"><i class=\"fa fa-smile-o\" style=\"font-size:22.5px;margin-right:5px;color:#55DAE1\"></i>" + data['compare_execution'].case_name + " "
      else
        com_title += "<div class=\"compare_info\"><i class=\"fa fa-bug\" style=\"font-size:22.5px;margin-right:5px;color:red\"></i>" + data['compare_execution'].case_name + " "

      cur_title += "<i class=\"fa fa-clock-o\"></i> " + data['current_execution'].created_at + "</div>"
      com_title += "<i class=\"fa fa-clock-o\"></i> " + data['compare_execution'].created_at  + "</div>"

      $("#compare_current_case_info").html(cur_title)
      $("#compare_select_case_info").html(com_title)

      isErrorInclude = false
      isCodeInclude = false
      isEndCodeInclude = false
      result = ""
      code = "No exception\n"
      if data['compare_execution'].exception
        code = ""
        for line in data['compare_execution'].exception.split("\n")
          if line.match(/^\s*E.*/)
            isErrorInclude = true
          if isErrorInclude
            result += line + "\n"

          if isEndCode
            continue

          if line.match(/^\s*(@pytest|def).*/)
            isCodeInclude = true

          if line.match(/^\s*>.*/)
            isEndCode = true
            isCodeInclude = false

          if isCodeInclude || isEndCode
            code += line + "\n"

      $("#compare_selected_case_error").html("<pre>" + result + "</pre>")
      $("#compare_selected_code").html(code)
      if not pytestSelectedCase
        if document.getElementById('compare_selected_code')
          pytestSelectedCase = CodeMirror.fromTextArea(document.getElementById('compare_selected_code'), {
            lineNumbers: true,
            mode: "text/x-cython",
            theme: 'monokai',
            readOnly: true
          });
      else
        console.log "here"
        pytestSelectedCase.setValue(code)
        $('#compare_selected_case_content').show()
        pytestSelectedCase.refresh()
    error:(data) ->
      console.log data
  })

@load_execution_compare_with = (id) ->
  $('#compare_selected_case_content').hide("drop", { direction: "right" }, ->
    params={}
    params['compare_id']=id
    $.ajax({
      type: "POST",
      url: document.URL+"/getCompareExecution",
      data: params
      success:(data) ->
        console.log data
        com_title = ""

        if data['compare_execution'].result is "passed"
          com_title += "<div class=\"compare_info\"><i class=\"fa fa-smile-o\" style=\"font-size:22.5px;margin-right:5px;color:#55DAE1\"></i>" + data['compare_execution'].case_name + " "
        else
          com_title += "<div class=\"compare_info\"><i class=\"fa fa-bug\" style=\"font-size:22.5px;margin-right:5px;color:red\"></i>" + data['compare_execution'].case_name + " "

        com_title += "<i class=\"fa fa-clock-o\"></i> " + data['compare_execution'].created_at  + "</div>"

        $("#compare_select_case_info").html(com_title)
        isErrorInclude = false
        isCodeInclude = false
        isEndCodeInclude = false
        result = ""
        code = "No Exception\n"
        if data['compare_execution'].exception
          code = ""
          for line in data['compare_execution'].exception.split("\n")
            if line.match(/^\s*E.*/)
                isErrorInclude = true
            if isErrorInclude
              result += line + "\n"

            if isEndCode
              continue

            if line.match(/^\s*(@pytest|def).*/)
              isCodeInclude = true

            if line.match(/^\s*>.*/)
              isEndCode = true
              isCodeInclude = false

            if isCodeInclude || isEndCode
              code += line + "\n"

        $("#compare_selected_case_error").html("<pre>" + result + "</pre>")
        $("#compare_selected_code").html(code)
        pytestSelectedCase.setValue(code)
        $('#compare_selected_case_content').show()
        pytestSelectedCase.refresh()
      error:(data) ->
        console.log data
    })
  )

render_compare_execution = (id) ->
  params={}
  params['compare_id']=id
  $.ajax({
    type: "POST",
    url: document.URL+"/getCompareExecution",
    data: params
    success:(data) ->
      console.log data
      com_title = ""

      if data['compare_execution'].result is "passed"
        com_title += "<div class=\"compare_info\"><i class=\"fa fa-smile-o\" style=\"font-size:22.5px;margin-right:5px;color:#55DAE1\"></i>" + data['compare_execution'].case_name + " "
      else
        com_title += "<div class=\"compare_info\"><i class=\"fa fa-bug\" style=\"font-size:22.5px;margin-right:5px;color:red\"></i>" + data['compare_execution'].case_name + " "

      com_title += "<i class=\"fa fa-clock-o\"></i> " + data['compare_execution'].created_at  + "</div>"

      $("#compare_select_case_info").html(com_title)
      isErrorInclude = false
      isCodeInclude = false
      isEndCodeInclude = false
      result = ""
      code = "No Exception\n"
      if data['compare_execution']
        code = ""
        for line in data['compare_execution'].exception.split("\n")
          if line.match(/^\s*E.*/)
              isErrorInclude = true
          if isErrorInclude
            result += line + "\n"

          if isEndCode
            continue

          if line.match(/^\s*(@pytest|def).*/)
            isCodeInclude = true

          if line.match(/^\s*>.*/)
            isEndCode = true
            isCodeInclude = false

          if isCodeInclude || isEndCode
            code += line + "\n"

      $("#compare_selected_case_error").html("<pre>" + result + "</pre>")
      $("#compare_selected_code").html(code)
      pytestSelectedCase.setValue(code)
      $('#compare_selected_case_content').show()
      pytestSelectedCase.refresh()
    error:(data) ->
      console.log data
  })

@close_execution_compare_with = () ->
  $('#compare_full_screen_grey_layer').hide( "fold", {}, 'slow' );
  $('body').css('overflow','auto')

@dismiss_execution_compare_detail_exec_time = () ->
  $('.compare_execution_detail_exec_time_block').hide()

@show_execution_compare_detail_exec_time = (id,display_id) ->
  dismiss_execution_compare_detail_exec_time()
  rightPos = $('#' + id).offset().left + $('#' + id).outerWidth() + 5
  console.log $(window).scrollTop()
  topPos = $('#' + id).offset().top +  parseInt($('#' + id).css('height')) - 21.5 - parseInt($(window).scrollTop())
  $('#' + display_id).css('top' , topPos)
  $('#' + display_id).css('right' , rightPos)

  $('#' + display_id).show()
