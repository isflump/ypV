# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/
$(document).ready ->
  data = {
    labels: ["January", "February", "March", "April", "May", "June", "July"],
    datasets: [
        {
            label: "My First dataset",
            fillColor: "rgba(220,220,220,0.2)",
            strokeColor: "rgba(220,220,220,1)",
            pointColor: "rgba(220,220,220,1)",
            pointStrokeColor: "#fff",
            pointHighlightFill: "#fff",
            pointHighlightStroke: "rgba(220,220,220,1)",
            data: [65, 59, 80, 81, 56, 55, 40]
        },
        {
            label: "My Second dataset",
            fillColor: "rgba(151,187,205,0.2)",
            strokeColor: "rgba(151,187,205,1)",
            pointColor: "rgba(151,187,205,1)",
            pointStrokeColor: "#fff",
            pointHighlightFill: "#fff",
            pointHighlightStroke: "rgba(151,187,205,1)",
            data: [28, 48, 40, 19, 86, 27, 90]
        }
    ]
    }
  data2 = {
    labels: ["January", "February", "March", "April", "May", "June", "July"],
    datasets: [
        {
            label: "My First dataset",
            fillColor: "rgba(220,220,220,0.5)",
            strokeColor: "rgba(220,220,220,0.8)",
            highlightFill: "rgba(220,220,220,0.75)",
            highlightStroke: "rgba(220,220,220,1)",
            data: [65, 59, 80, 81, 56, 55, 40]
        },
        {
            label: "My Second dataset",
            fillColor: "rgba(151,187,205,0.5)",
            strokeColor: "rgba(151,187,205,0.8)",
            highlightFill: "rgba(151,187,205,0.75)",
            highlightStroke: "rgba(151,187,205,1)",
            data: [28, 48, 40, 19, 86, 27, 90]
        }
    ]
    }

  ctx = document.getElementById("myChart").getContext("2d")
  myNewChart = new Chart(ctx).Line(data)
  ctx2 = document.getElementById("myChart2").getContext("2d")
  myNewChart2 = new Chart(ctx2).Bar(data2)

  pytestCase = CodeMirror.fromTextArea(document.getElementById('code'), {
    lineNumbers: true,
    mode: "text/x-cython",
    theme: 'monokai'
  });
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
  if !$('#report_image_large_view_max_btn').hasClass('hide')
    $('#report_image_large_view_max_btn').addClass('hide')
  if !$('#report_image_large_view_reg_btn').hasClass('hide')
    $('#report_image_large_view_reg_btn').addClass('hide')
  $('body').css('overflow','auto')


@report_image_next = () ->
  $('#enlarged_img').hide("drop")
  current_image_view_id_dup = current_image_view_id
  setTimeout (->
    $('#enlarged_img').attr('src', $('#report_image_' + String(parseInt(current_image_view_id_dup.split('_')[current_image_view_id_dup.split('_').length-1]) + 1)).attr('src'))
    $('#enlarged_img').show("drop", { direction: "right" })
    ), 450
  $('#report_image_prev').show()
  if !$('#report_image_' + String(parseInt(current_image_view_id_dup.split('_')[current_image_view_id_dup.split('_').length-1]) + 2)).length > 0
    $('#report_image_next').hide()
    current_image_view_id = 'report_image_' + String(parseInt(current_image_view_id_dup.split('_')[current_image_view_id_dup.split('_').length-1]) + 1)

@report_image_prev = () ->
  $('#enlarged_img').hide("drop", { direction: "right" })
  current_image_view_id_dup = current_image_view_id
  $('#report_image_next').show()
  setTimeout (->
    $('#enlarged_img').attr('src', $('#report_image_' + String(parseInt(current_image_view_id_dup.split('_')[current_image_view_id_dup.split('_').length-1]) - 1)).attr('src'))
    $('#enlarged_img').show("drop")
    ), 450
  if parseInt(current_image_view_id_dup.split('_')[current_image_view_id_dup.split('_').length-1]) - 1 == 0
    $('#report_image_prev').hide()
    current_image_view_id = 'report_image_' + String(parseInt(current_image_view_id_dup.split('_')[current_image_view_id_dup.split('_').length-1]) - 1)

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
