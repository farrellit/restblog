updatePostList = function(){
	$("#postlist").html("Refreshing...")
	$.get( "/posts", null, function(d){
		$("#postlist").html( "" )
		for( i in d.posts ){  // should be array
			$("#postlist").append("<p><a href='/posts/"+ i +"' >"+ d.posts[i].title +"</a></p>" )
		}
		if( d.posts.length == 0 ){
			$("#postlist").html( "<p><em>No Posts.</em></p>" )
		}
	}, "json" );
}
saveNewPost = function(){
	var data = {
		postname: $('#postname').val(),
		title: $('#posttitle').val(),
		body: $('#postcontent').val()
	}
	var alerts = "";
	if(data.postname.length == 0){
		alerts += "Please supply a post name.\n";
	}
	if(data.title.length == 0){
		alerts += "Please supply a post title.\n";
	}
	if( data.body.length == 0){
		alerts += "Please supply a post body.\n";
	}
	if( alerts.length > 0){
		alert(alerts);
	} else {
		$.post( "/posts/"+data.postname, data, updatePostList )
	}
}
$(document).ready( updatePostList );

