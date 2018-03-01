# $(document).delegate ".comment_edit_form_link", 'click', (e)->
#   e.preventDefault()
#   link = $(e.currentTarget)
#   target = $(link.attr('href'))
#   $('.comment_edit_form').addClass('hidden').closest('.comment_block').find(".content_block").removeClass('hidden')
#   target.removeClass('hidden').closest('.comment_block').find(".content_block").addClass('hidden')
#
# $(document).delegate ".comment_delete_form_link", 'click', (e)->
#   e.preventDefault()
#   link = $(e.currentTarget)
#   target = $(link.attr('href'))
#   target.find('form').prepend("<input type='hidden' name='_method' value='delete'></input>").submit()


$(document).on "click", "#rails_admin_model_settings .inline-edit", (e)->
  e.preventDefault()
  link = $(e.currentTarget)
  span = link.parent()
  span.siblings('.rails_admin_model_settings_inline_form.hidden').removeClass('hidden').find('form').data("remote", "true")
  # span.siblings('.navigate-block').find('a').attr("target", "_blank")
  span.siblings(".setting_value").andSelf().remove()
  $("#edit_rails_admin_settings_setting .raw_array_field").find(":input[type='hidden']").trigger('change')
  return false



$(document).on "ajax:send", "#rails_admin_model_settings_wrapper .update-settings a", (e, data, status, xhr)->
  $("#rails_admin_model_settings").hide()

$(document).on "ajax:success", "#rails_admin_model_settings_wrapper .update-settings a", (e, data, status, xhr)->
  $("#rails_admin_model_settings").replaceWith($(data).find("#rails_admin_model_settings"))

$(document).on "submit", ".rails_admin_settings_inline_form form", (e)->
  if $("#rails_admin_model_settings_wrapper #auto_update:checked").length > 0
    $(e.currentTarget).hide()
    setTimeout(->
      $("#rails_admin_model_settings_wrapper .update-settings a").trigger("click")
    , 1000)
  else
    setTimeout(->
      $(e.currentTarget).find("[type='submit']").removeAttr("disabled")
    , 1000)
