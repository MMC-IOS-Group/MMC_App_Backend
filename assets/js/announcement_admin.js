(function($) {

    // setting up for the Post New Announcement dialog

    function setupPostDialog() {

        var $newDialog = $('#newDialog');
        var tmpl = $('#rowTemplate').html();

        $newDialog .modal({
            show: false,
        });


        $('#newAnnouncementBtn').click(function(e) {
            e.preventDefault();
            // reset input fields
            $('#newDialog input, #newDialog textarea').val('');
            $newDialog.modal('show');
        });

        // AJAX Submit

        $('#newDialog #submitBtn').click(function() {
            if ($newDialog.find('input').val() === "" || $newDialog.find('textarea').val() === '') {
                alert('You must fill in both value before submitting.');
            }
            $.ajax({
                type: 'POST',
                url: '/admin/announcements/',
                dataType: 'json',
                data: {
                    title: $('input[name=title]').val(),
                    content: $('textarea[name=content]').val()
                },
                success: function(data) {

                    // return a date in this format: mm/dd/yyyy at HH:MMpm
                    function formatDate(dat) {
                        // mm/dd/yyyy at hh:mm pm
                        var month = dat.getMonth() + 1;
                        month = month < 10 ? "0" + month : "" + month;
                        var date = dat.getDate();
                        date= date < 10 ? "0" + date : "" + date;
                        var year = dat.getFullYear() - 2000;

                        var hour = dat.getHours() % 12;
                        if (hour == 0) { hour = 12; }
                        hour = hour < 10 ? "0" + hour : "" + hour;
                        var min = dat.getMinutes();
                        min = min < 10 ? "0" + min : "" + min;
                        var pm = dat.getHours() < 12 ? "am" : "pm";

                        return month + "/" + date + "/" + year + " at " + hour + ":" + min + pm;
                    }

                    // create new row
                    $('tbody').prepend(tmpl);
                    var $row = $('tbody tr').first();

                    var dat = new Date(data.created_at);
                    // puts in received content
                    $row.find('.title').text(data.title);
                    $row.find('.username').text(data.user_name);
                    $row.find('.time-posted').text(formatDate(dat));

                    // only admin should have the delete button
                    if (data.user_role != 2) {
                        $row.find('deleteBtn').remove();
                    } else {
                        $row.find('deleteBtn').attr('data-id', data.id);
                    }

                    $row.next().find('div').html(data.content);

                    $('tbody').prepend($row);
                    $('#newDialog').modal('hide');

                },
                error: function() {
                }
            });
        });

    }

    // set up click handlers for the whole table
    function setupTable() {
        $('table').click(function(e) {

            if (e.target.nodeName === "TD") {
                $(e.target).parent().find('.viewBtn').click();
            }
            if (e.target.nodeName !== "A") {
                return true;
            }

            e.preventDefault();

            var $btn = $(e.target);
            // view button
            if ($btn.hasClass('viewBtn')) {
                if ($btn.text() === 'View') {
                    $btn.parent().parent().next().find('div').slideToggle(200);
                    $btn.text('Hide');
                } else {
                    $btn.parent().parent().next().find('div').slideToggle(200);
                    $btn.text('View');
                }
            } else if ($btn.hasClass('deleteBtn')) {
                var prompt = confirm('Are you sure you want to delete this announcement?');
                if (prompt) {
                    $.ajax('/admin/announcements/' + $btn.attr('data-id'), {
                        type: 'delete',
                        success: function(jqXHR, textStatus) {
                            $btn.parent().parent().remove();
                        },
                        error: function(jqXHR, textStatus, errorThrown) {
                            if (jqXHR.status= 401) {
                                alert("You are not authorized to delete this announcement.");
                            } else {
                                alert("An error has occured while trying to delete this announcement.")
                            }
                        },
                    });
                }
            }


        });
    }

    $(document).ready(function() {

        $('[data-toggle="tooltip"]').tooltip({container: 'body'});
        $('.announcement-content div').hide();

        $('#sidebar').affix({
            offset: $('#sidebar').offset().top  - $('.nav').height()
        });

        setupPostDialog();
        setupTable();


    });
}(jQuery))
