// TODO: this is a Node module


-- Port:
--  pass notification permissions to elm
--  read notification info from elm
--  read message to authorize from elm

function askNotificationPermission() {

  function requestPermission() {
    try {
      Notification.requestPermission().then();
    } catch(e) {
      Notification.requestPermission(function(permission) {
        handlePermission(permission);
      });
    }
    Notification.requestPermission().then(handlePermission);
  }

  function handlePermission(permission) {
    if(Notification.permission === 'denied' || Notification.permission === 'default') {
        console.log("No Notifications :(");
    } else {
        // TODO: send to port that notifications are allowed
        console.log("Notifications enabled");
    }
  }

  if (!('Notification' in window)) {
    console.log("This browser does not support notifications.");
  } else {
    requestPermission()
  }
}
