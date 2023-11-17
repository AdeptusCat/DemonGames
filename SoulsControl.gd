extends Control


#var souls: Array:
	#set(array):
		#rankTrack = array
		#rankTrackLabel.clear()
		#for rank in rankTrack:
			#rankTrackLabel.add_text(str(rank) + "\n")
