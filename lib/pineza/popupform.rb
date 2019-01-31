require 'erb'

require_relative 'modules'

class Pineza::PopupForm
	Template = %{
		<form id="popup-form">
			<table class="popup-table">
				<% for property, value in properties %>
					<tr class="popup-table-row">
						<th class="popup-table-header"> <%= property %>: </th>
						<td> <input id="inp_<%= property %>" class="popup-table-data" value="<%= value %>" /> </td>
					</tr>
				<% end %>
			</table>

			<button id="button-submit" type="button">Submit</button>
		</form>
	}

	class << self
		def generate(properties)
			ERB.new(Template, 0, "").result(binding)
		end
	end
end
