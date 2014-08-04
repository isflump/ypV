# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/
$(document).ready ->
  console.log(document.URL)
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
