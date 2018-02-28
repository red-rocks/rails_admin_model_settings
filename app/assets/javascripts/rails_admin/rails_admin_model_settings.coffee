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
  span.siblings('.rails_admin_model_settings_inline_form.hidden').removeClass('hidden').find('form').attr("target", "_blank")
  # span.siblings('.navigate-block').find('a').attr("target", "_blank")
  span.siblings(".setting_value").andSelf().remove()
  return false
