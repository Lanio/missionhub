$ ->
  $(document).ready ->

    $(document).on "click", ".side-search-option .toggler", (e)->
      fields = $(this).siblings(".fields")
      if fields.is(":visible")
        $(this).siblings(".fields").slideUp()
        $(this).removeClass("active")
      else
        $(this).siblings(".fields").slideDown()
        $(this).addClass("active")
