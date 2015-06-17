function maintainStatus() {
  $.ajaxSetup({cache: false});
  
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

  function getDemoLater() {
    setTimeout(getDemo, POLL_INTERVAL_MS);
  }

  function updateStatus(data) {
    if (data.demo.status == 'provisioned') {
      $("[data-status='provisioning']").hide();
      $('#demo_button').attr('href', data.demo.published_url);
      $("[data-status='ready']").show();

      return;
    }

    if (data.demo.status == 'provisioning') {
      $("[data-status='confirmed']").hide();
      $("[data-status='provisioning']").show();
      $('#provisioning_status').html(data.demo.provisioning_status.message);
      $('#provisioning_percent_complete').html(data.demo.provisioning_status.percent_complete);
      $('#provisioning_progressbar')[0].value = data.demo.provisioning_status.percent_complete;
    }

    getDemoLater();
  }

  function handleError(error) {
    var data = $.parseJSON(error.responseText)
    $("[data-status='provisioning']").hide();
    $("#error_text").html(data.demo.provisioning_error);
    $("[data-status='error']").show();
  }
}