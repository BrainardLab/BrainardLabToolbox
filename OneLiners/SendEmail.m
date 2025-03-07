function SendEmail(recipients, subject, body, sender)
% SendEmail - Sends an email.
%
% Description:
% Send an email using the intra campus UPenn SMTP open relay.
%
% Syntax:
% SendEmail(recipients, subject, body);
% SendEmail(recipients, subject, body, sender)
%
% Input:
% recipients (string|cell array) - The email address(es) of the recipients.
%     Single addresses are specified as a string, whereas multiple
%     recipients are specified as a cell array of strings.  If
%     recipients is empty, the routine does not try to send the email.
% subject (string) - The subject of the email.
% body (string) - The body, i.e. main text, of the email message.
% sender (string) - Email address of the sender.  Default:
%     colorlab@psych.upenn.edu

% 7/27/17  dhb  Update for narginchk.

% Validate the number of inputs.
narginchk(3, 4);

if ~exist('sender', 'var')
    sender = 'colorlab@psych.upenn.edu';
end

% Set the SMTP server.
setpref('Internet', 'SMTP_Server', 'smtp-relay.upenn.edu');

% Set the sender's e-mail address.
setpref('Internet', 'E_Mail', sender);

% Send the e-mail.
if (~isempty(recipients))
    try
        sendmail(recipients, subject, body);
    catch e
        fprintf('\nERROR: `sendmail` command did not succeed. Proceeding anyway.\n');
    end
end