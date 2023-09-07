var FeedbackTable = []
var currentWindowID, currentWindow
var windowStatus = "closed"
var closeKey = "27"

window.addEventListener('message', function(event) {
	switch (event.data.action) {
		case 'ClientFeedback':
			windowStatus = "feedback"
			$(".feedback").fadeIn()
			break
		case 'OpenAdminFeedback':
			$(".feedbackWindow").hide()
			windowStatus = "FeedbackTable"
			$(".feedbackWrapper").fadeIn()
			$(".feedbackTable").show()
			break
		case 'updateFeedback':
			FeedbackTable = event.data.FeedbackTable
			reloadFeedbackTable()
			break
	}
});

function checkIfEmpty() {
	if(document.getElementById("feedback_subject-input").value === "" || document.getElementById("feedback_information-input").value === "") {
		document.getElementById('submitFeedback').disabled = true;
	} else { 
	document.getElementById('submitFeedback').disabled = false;
	}
}

$(document).on('click', "#submitFeedback", function() {
	var category = $("input[name='category']:checked").val()
	var subject = $("#feedback_subject-input").val()
	var information = $("#feedback_information-input").val()

	$(".feedback").fadeOut();

	$.post('https://lpsystem/action', JSON.stringify({
		action: "newFeedback",
		subject: subject,
		information: information,
		category: category,
	}));

	cleanFeedback();
	document.getElementById("submitFeedback").disabled = true;  

	windowStatus = "closed"
});

function cleanFeedback() {
	$("#feedback_subject-input").val("");
	$("#feedback_information-input").val("")
}

$(document).on('click', ".closeFeedback", function() {
	$(".feedback").fadeOut();

	$.post('https://lpsystem/action', JSON.stringify({
		action: "close",
	}));

	cleanFeedback();

	windowStatus = "closed"
});

$(document).on('click', ".closeFeedbackWindow", function() {
	$(".feedbackWindow").hide();
	$(".feedbackTable").show();

	windowStatus = "FeedbackTable"
})

$(document).on('click', ".closeFeedbackTable", function() {
	$(".feedbackWrapper").fadeOut();
	$.post('https://lpsystem/action', JSON.stringify({
		action: "close",
	}));

	windowStatus = "closed"
});

function viewFeedbackWindow(feedbackid) {
	currentWindowID = feedbackid
	$(".feedbackTable").hide();
	var feedbackW = $(".feedbackWindow");
	var data = FeedbackTable[feedbackid]
	currentWindow = data
	feedbackW.show();
	feedbackW.find(".feedback_id").html(`${data.feedbackid}`)
	feedbackW.find(".player_id").html(`${data.playerid}`)
	feedbackW.find(".player_identifier").html(`${data.identifier}`)
	var feedbackWcard = feedbackW.find(".card-body")
	feedbackWcard.find(".feedback_subject").val(`${data.subject}`)
	feedbackWcard.find(".feedback_information").html(`${data.information}`)


}

$(document).on('click', ".table-row .btn-view", function() { 
	var feedbackid = $(this).parent().parent().attr("feedbackID")
	viewFeedbackWindow(feedbackid)

	windowStatus = "viewFeedback"
});

$(document).on('click', ".feedbackWindow .btn-goback", function() { 
	$(".feedbackWindow").hide();
	$(".feedbackTable").show();

	windowStatus = "FeedbackTable"
});

$(document).on('click', ".btn-assist", function() { 
	$(".feedbackWrapper").fadeOut();
	$.post('https://lpsystem/action', JSON.stringify({
		action: "assistFeedback",
		feedbackid: currentWindow.feedbackid
	}));

	windowStatus = "closed"
});

$(document).on('click', ".btn-conclude", function() { 
	ConcludeFeedback(currentWindow.feedbackid, false)
	$(".feedbackWindow").hide();
	$(".feedbackTable").show();

	windowStatus = "FeedbackTable"
});

function ConcludeFeedback(feedbackid, canConclude) {
	$.post('https://lpsystem/action', JSON.stringify({
		action: "concludeFeedback",
		feedbackid: feedbackid,
		canConclude: canConclude
	}));
}

$(document).ready(function(){
	document.onkeyup = function(data) {
		if (data.which == closeKey) {
			switch (windowStatus) {
				case 'feedback' :
					cleanFeedback();
					$(".feedback").fadeOut()
					$.post('https://lpsystem/action', JSON.stringify({
						action: "close",
					}));
					windowStatus = "closed"
					break
				case 'FeedbackTable' :
					$(".feedbackWrapper").fadeOut()
					$.post('https://lpsystem/action', JSON.stringify({
						action: "close",
					}));
					windowStatus = "closed"
					break
				case 'viewFeedback' :
					$(".feedbackWindow").hide()
					$(".feedbackTable").show()
					windowStatus = "FeedbackTable"
				break
			}
		}
	};
});

function reloadFeedbackTable() {
	var feedbackTable = $(".feedbackTable").find(".table")

	FeedbackTable.sort(function(a, b) { 
		return a.feedbackid - b.feedbackid
	})

	feedbackTable.html("");

	$.each(FeedbackTable, function(id, feedback) {
		var category = ""
		var concluded =  "<span><i class='fas fa-times-circle'></i></span>"
		var statusColor = "#fc1000"
	

		if (feedback.concluded === "assisting") {
			concluded = "<span><i class='fas fa-hands-helping'></span>"
			statusColor = "#11ff00"
		}

		if (feedback.concluded != true) {
			feedbackTable.append(`
				<tr class="table-row" feedbackID="${id}">
					<td>LP ${feedback.feedbackid}</th>
					<td>${category}</td>
					<td style="color: ${statusColor};">${concluded}</td>
					<td><button type="button" class="btn btn-view"><i class="fas fa-eye"></i> VIDI</button></td>
				</tr>`
			)
		}
	});
}