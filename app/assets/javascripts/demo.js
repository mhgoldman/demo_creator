function maintainStatus() {
  getDemo();

  function getDemo() {
    var ajaxOptions = {
      type: "GET",
      url: window.location.href,
      dataType: "json",
      contentType: "application/json; charset=utf-8"
    };

    $.ajax(ajaxOptions).done(updateStatus).fail(handleError);
  }

  function getDemoIn5Secs() {
    setTimeout(getDemo, 5000);
  }

  function updateStatus(data) {
    if (data.status == 'provisioned') {
      $("[data-status='provisioning']").hide();
      $("[data-status='ready']").show();
      $('demo_button').click = function() {
        window.location = data.published_url;
      };
    }
    else {
      getDemoIn5Secs();
    }
  }

  function handleError(error) {
    var demo = $.parseJSON(error.responseText)
    $("[data-status='provisioning']").hide();
    $("#error_text").html(demo.provisioning_error);
    $("[data-status='error']").show();
  }
}