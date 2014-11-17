function setNotificationPreferences(obj)
    % Set email notification preference
    setpref('Internet', 'SMTP_Server', 'smtp-relay.upenn.edu');
    setpref('Internet', 'E_Mail', obj.cal.describe.doneNotificationEmail);
end
