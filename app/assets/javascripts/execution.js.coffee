# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/
$(document).ready ->
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
            #"rgba(220,220,220,1)"
            pass_color="rgba(70, 191, 189,0.5)"
            red_color="rgba(247, 70, 74,0.5)"
            line = {
              labels: data['label'],
              datasets: [
                  {
                      title: "Accumulated"
                      label: "My First dataset",
                      fillColor: "rgba(220,220,220,0.2)",
                      strokeColor: "rgba(220,220,220,1)",
                      pointColor: "rgba(220,220,220,1)",
                      pointStrokeColor: "#fff",
                      pointHighlightFill: "#fff",
                      pointHighlightStroke: "rgba(240,240,240,1)",
                      data: data['executionNumber']
                  },
                  {
                      label: "My Second dataset",
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
                      highlightFill: pass_color,
                      highlightStroke: pass_color,
                      data: data['lastExecutionPass']
                  },
                  {
                      label: "My Second dataset",
                      title: 'Failed'
                      fillColor: red_color,
                      strokeColor: red_color,
                      highlightFill: red_color,
                      highlightStroke: red_color,
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
          #showError('Error on request',data)
      })


  $.ajax({
				type: "POST",
				url: document.URL+"/getSpira",
				data: ''
				success:(data) ->
          console.log(data)
          if data['foundCase'] is false
            $("#spiralog").html("<div class=\"spira_description\">
              <font style=\"font-size:17px; font-weight:bold;color:#ddd\">Cannot find Spira case corespond to this test:</font>
              </div>")
          else
            content = "<div class=\"spira_description\">
                  <font style=\"font-size:17px; font-weight:bold;color:#ddd\">Description:</font><br><pre>"+data['tcDescription']+"</pre></font>
                  </div>
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
				error:(data) ->
					#showError('Error on request',data)
			})

legend = (parent, data) ->
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
