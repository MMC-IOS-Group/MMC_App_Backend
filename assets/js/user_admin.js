$(document).ready(function() {

    function setupEditDialog() {
        var $editDialog = $('#editDialog')
        $editDialog.modal({show: false}); 

        $('table').click(function(e) {
            // if click on edit button

            if ($(e.target).hasClass('deleteBtn')) {
                var c = confirm("Are you sure you want to delete this user");
                e.preventDefault();
                if (c) {
                    var id = $(e.target).parent().attr('data-id');
                    $.ajax({
                        type: 'DELETE',
                        url:' /admin/users/' + id,
                        success: function(data) {
                            var $btn = $(e.target);
                            $btn.parent().parent().remove();
                        },
                        error: function() {
                            alert("An error has occured. Please try again later.");
                        },
                    });
                }
            } else if ($(e.target).hasClass('editBtn')) {
                e.preventDefault();
                var $btn = $(e.target);
                var name = $btn.parent().attr('data-name');
                var role = $btn.parent().attr('data-role');
                var id = $btn.parent().attr('data-id');

                $editDialog.find('[name="name"]').val(name);
                $editDialog.find('[name="role"]').val(role);
                $editDialog.modal('show');

                // AJAX submit
                $editDialog.find('#submitBtn').click(function() {
                    if ($editDialog.find('[name=name]').val().length === 0) {
                        alert("The user's name must not be empty.");
                    }
                    $.ajax({
                        type: 'PUT',
                        url: '/admin/users/' + id,
                        dataType: 'json',
                        data: {
                            name: $('[name=name]').val(),
                            role: $('[name=role]').val(),
                        },
                        success: function(data) {
                            var $row = $btn.parent().parent();
                            $row.find('.name').text(data.name);
                            $row.find('.role').text(data.role_name);
                            $row.find('.action').attr({
                                'data-name': data.name,
                                'data-role': data.role,
                                'data-id': data.id,
                            });
                            $editDialog.modal('hide');
                        },
                        error: function() {
                            alert("An error has occured. Please try again later.");
                        }
                    });

                });
            }
        });
    }

    setupEditDialog();
});
