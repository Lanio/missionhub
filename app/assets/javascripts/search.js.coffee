$ ->
  $(document).ready ->

    $(document).on "click", ".side-search-option .toggler", (e)->
      fields = $(this).siblings(".fields")
      if fields.is(":visible")
        fields.slideUp("fast")
        $(this).removeClass("active")
      else
        fields.slideDown("fast")
        $(this).addClass("active")

    $(document).on "click", ".side-search-option .title", (e)->
      $(this).siblings(".toggler").click()

    $(document).on "click", ".side-search .side-search-toggler", (e)->
      toggler= $(this)
      fields = toggler.siblings(".side-search-options")
      if fields.is(":visible")
        toggler.removeClass("active")
        fields.slideUp "fast"
      else
        toggler.addClass("active")
        fields.slideDown "fast"