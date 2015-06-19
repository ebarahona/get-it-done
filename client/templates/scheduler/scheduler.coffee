EVENT_CTRLS = '<div class="event-ctrls"><span class="remove-event"><i class="fa fa-minus"></i></span></div>'

Template.scheduler.helpers
	calendarOptions: () ->
		{
			eventRender: (event, element) ->
        element.append EVENT_CTRLS
			events: (start, end, timezone, callback) ->
      	callback Chips.find().map (el) ->
        		board = Boards.findOne(el.boardId)
        		el.title = board.title
        		el.color = board.config.bgColor
        		el
			defaultView: 'agendaWeek'
			allDaySlot: false
			editable: true
			overlap: true
			height: "auto"
			id: 'calendar'
			header: {
				left:   'title',
				center: '',
				right:  'month,agendaWeek,agendaDay today prev,next'
			}
			timezone: 'local'
			selectable: true
			select: ( start, end, jsEvent, template ) ->
				Modal.show 'newChipModal', 
					start: start
					end: end
			eventDrop: (event, delta, revertFunc, jsEvent, ui, view ) ->
				updateChip event
			eventResize: ( event, jsEvent, ui, view ) ->
				updateChip event
			eventClick: ( event, jsEvent, view ) ->
				className = jsEvent.target.className
				if className == 'remove-event' or className == 'fa fa-minus'
					Chips.remove {_id: event._id}, (err, res) ->
						console.log err or res
				else
					Router.go 'boards', { },
						hash: event.boardId
					#console.log 'go to board ', event.boardId
		}

Template.scheduler.onRendered ()->
	Meteor.setTimeout (->
  	refetchEvents()
	), 100
	Chips.after.insert refetchEvents
	Chips.after.remove refetchEvents
	Chips.after.update refetchEvents

	
refetchEvents = () ->
	$('#calendar').fullCalendar 'refetchEvents'

updateChip = (event) ->
	Chips.update {_id: event._id}, {$set: {start: event.start.format(), end: event.end.format()}}, (err, res) ->
		console.log err or res

createChip = (start, end, boardId) ->
	Chips.insert { start: start, end: end, boardId: boardId }, (err, res) ->
		console.log err or res