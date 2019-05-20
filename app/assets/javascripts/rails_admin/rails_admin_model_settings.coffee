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
  form = span.siblings('.rails_admin_model_settings_inline_form.hidden').removeClass('hidden need-hidden').find('form')
  form.data("remote", "true")
  # span.siblings('.navigate-block').find('a').attr("target", "_blank")
  span.siblings(".setting_value").andSelf().addClass('hidden need-hidden')
  form.find("#edit_rails_admin_settings_setting .raw_array_field").find(":input[type='hidden']").trigger('change')
  # hardfix
  form.find('.CodeMirror').each (i, el)->
    el.CodeMirror.refresh()
  return false


$(document).on "click", "#rails_admin_model_settings_wrapper .toggle-block a", (e)->
  toggle_block = $(e.currentTarget).closest('.toggle-block')
  toggle_block.toggleClass('opened')
  rails_admin_model_settings_inline_form = toggle_block.siblings('.rails_admin_model_settings_inline_form')
  setting_value = toggle_block.siblings('.setting_value')
  rails_admin_model_settings_inline_form.toggleClass("hidden") unless rails_admin_model_settings_inline_form.is('.need-hidden')
  setting_value.toggleClass("hidden") unless setting_value.is('.need-hidden')


# update all settings
$(document).on "ajax:send", "#rails_admin_model_settings_wrapper .update-settings a", (e, data, status, xhr)->
  $("#rails_admin_model_settings").hide()

$(document).on "ajax:success", "#rails_admin_model_settings_wrapper .update-settings a", (e, data, status, xhr)->
  $("#rails_admin_model_settings").replaceWith($(data).find("#rails_admin_model_settings"))
  $(document).trigger('rails_admin.dom_ready', [$("#rails_admin_model_settings")])

# update setting
$(document).on "ajax:send", "#rails_admin_model_settings_wrapper .setting_block .update-setting a", (e, data, status, xhr)->
  $(e.currentTarget).closest(".setting_block").hide()

$(document).on "ajax:success", "#rails_admin_model_settings_wrapper .setting_block .update-setting a", (e, data, status, xhr)->
  $(e.currentTarget).closest(".setting_block").replaceWith($(data).addClass("new-setting"))
  setTimeout(->
    $("#rails_admin_model_settings_wrapper .setting_block.new-setting").removeClass("new-setting")
  , 2000)
  $(document).trigger('rails_admin.dom_ready', [$("#rails_admin_model_settings_wrapper .setting_block.new-setting")])


# delete setting
$(document).on "ajax:send", "#rails_admin_model_settings_wrapper .setting_block .delete-setting a", (e, data, status, xhr)->
  $(e.currentTarget).closest(".setting_block").hide()

$(document).on "ajax:success", "#rails_admin_model_settings_wrapper .setting_block .delete-setting a", (e, data, status, xhr)->
  $(e.currentTarget).closest(".setting_block").remove()
  # $(e.currentTarget).closest(".setting_block").replaceWith($(data).addClass("new-setting"))
  # setTimeout(->
  #   $("#rails_admin_model_settings_wrapper .setting_block.new-setting").removeClass("new-setting")
  # , 2000)
  # $(document).trigger('rails_admin.dom_ready', [$("#rails_admin_model_settings_wrapper .setting_block.new-setting")])
# delete settign error -> update
$(document).on "ajax:error", "#rails_admin_model_settings_wrapper .setting_block .delete-setting a", (e, data, status, xhr)->
  $(e.currentTarget).closest(".setting_block").find(".update-setting a").trigger("click")
  


$(document).on "submit", ".rails_admin_settings_inline_form form", (e)->
  if $("#rails_admin_model_settings_wrapper #auto_update:checked").length > 0
    form = $(e.currentTarget)
    setting_block = form.closest(".setting_block")
    form.hide()
    setTimeout(->
      setting_block.find(".update-setting a").trigger("click")
    , 1000)
  else
    setTimeout(->
      $(e.currentTarget).find("[type='submit']").removeAttr("disabled")
    , 1000)



$(document).on "change blur keypress keyup keydown", "#rails_admin_model_settings_wrapper .filter-settings #filter", (e)->
  search_field = $(e.currentTarget)
  search_q = search_field.val()
  return if search_q == search_field.data("old-value")
  search_field.data("old-value", search_q)
  $("#rails_admin_model_settings .setting_block").each ->
    me = $(this)
    me.find(".filterable").each ->
      that = $(this)
      filterable_content = (that.data("filterable") || that.text()).toString()
      if filterable_content.indexOf(search_q) == -1
        me.addClass("filtered")
      else
        me.removeClass("filtered")
        return false
    return true



$(document).on "ajax:complete ajax:remotipartComplete", ".rails_admin_model_settings_inline_form form", (e, data, status, xhr)->
  if $("#rails_admin_model_settings_wrapper #auto_update:checked").length > 0
    form = $(e.currentTarget)
    form.closest('.rails_admin_model_settings_inline_form').siblings('.update-setting').find('a').click()
    
