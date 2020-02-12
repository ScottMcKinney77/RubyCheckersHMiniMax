require 'Set'

H_MINI_MAX_DEPTH = 100

class State  
	def initialize(dim)  
		@dim = dim
		@board = Array.new(dim*dim,0)
		@numB = 0
		@numW = 0   
	end  
	def setNumB(j)
		@numB = j
	end
	def setNumW(j)
		@numW = j
	end
	def getNumB
		return @numB
	end
	def getNumW
		return @numW
	end
	def getDim  
		return @dim
	end
	def putAt(i,j,element)
		@board[i*@dim+j] = element
	end
	def putAtIndex(i,element)
		@board[i] = element
	end
	def boardGetRowCol(ind)
		j = ind.modulo(8)
		i = (ind-j)/8
		return "[#{i},#{j}]"
	end

	def checkCapture(i,num,dir)
		if (i+num+1).modulo(8) == 0 || (i+num).modulo(8) == 0
			return false
		end
		#CAPTURE
		n2 = @board[i+num+num]
		if n2 == 0
			potCapturesObject = Array.new()
			potCapturesObject << Array.new()
			potCapturesObject[0] << (i+num+num)

			secCaptures = checkSecondaryCaptures(i+num+num, dir, potCapturesObject)
			return secCaptures
		else
			return false
		end
	end

	def checkSecondaryCaptures(i,dir, potCapturesObject)
		branchFlag = 0
		if dir == 1
			whoseNotTurn = 1
		else
			whoseNotTurn = 2
		end
		s1 = @board[i+dir*7]
		s2 = @board[i+dir*9]

		if ((i+dir*7).modulo(8) != 0) && ((i+dir*7).modulo(8) != 0 && (i+dir*7+dir*7).modulo(8) != 0) && ((i+dir*7+dir*7).modulo(8) != 0)
			if (s1 == whoseNotTurn) || (s1 == whoseNotTurn+2)
				num = dir*7
				if @board[i+num+num] == 0 && i+num+num >= 0 && i+num+num <= 63
					branchFlag = 1
					potCapturesObject[potCapturesObject.size-1] << (i+num+num)
					checkSecondaryCaptures(i+num+num,dir,potCapturesObject)
				end
			end
		end
		if ((i+dir*9).modulo(8) != 0) && ((i+dir*9).modulo(8) != 0 && (i+dir*9+dir*9).modulo(8) != 0) && ((i+dir*9+dir*9).modulo(8) != 0)
			if (s2 == whoseNotTurn) || (s2 == whoseNotTurn+2)
				num = dir*9
				if @board[i+num+num] == 0 && i+num+num >= 0 && i+num+num <= 63
					if branchFlag == 1
						temp = potCapturesObject[potCapturesObject.size-1].map(&:clone)
						temp[temp.size-1] = (i+num+num)
						potCapturesObject << temp
						checkSecondaryCaptures(i+num+num,dir,potCapturesObject)
					else
						potCapturesObject[potCapturesObject.size-1] << (i+num+num)
						checkSecondaryCaptures(i+num+num,dir,potCapturesObject)
					end
					
				end
			end
		end
		return potCapturesObject
	end

	def getAllMoves(whosTurn)
		longestCapture = 0
		possibleMoves = Set.new
		if whosTurn == 1
			dir = -1
		else
			dir = 1
		end
		i = 0
		@board.each do |q|
			if q == whosTurn
				if (i+1).modulo(8) == 0
					#right hand edge
					if dir == 1
						num = 7
					else
						num = -9
					end
					n = @board[i+num]
					if n != whosTurn && n != whosTurn+2
						#empty or enemy peice there
						if n == 0
							if longestCapture == 0 #Only add regular moves if there are no captures available
								possibleMoves.add(["n",i,i+num])
							end
						else
							tempArr = checkCapture(i,num, dir)
							if tempArr != false
								tempArr.each do |p|
									if p.length > longestCapture
										possibleMoves.clear
										longestCapture = p.length
										temp = Array.new
										temp << "c"
										temp << i
										p.each do |q|
											temp << q
										end
										possibleMoves.add(temp)
									elsif p.length == longestCapture
										temp = Array.new
										temp << "c"
										temp << i
										p.each do |q|
											temp << q
										end
										possibleMoves.add(temp)
									end
								end 
							end
						end
					end
				elsif i.modulo(8) == 0
					#left hand edge
					if dir == 1
						num = 9
					else
						num = -7
					end
					n = @board[i+num]
					if n != whosTurn && n != whosTurn+2
						#empty or enemy peice there
						if n == 0
							if longestCapture == 0 #Only add regular moves if there are no captures available
								possibleMoves.add(["n",i,i+num])
							end 
						else
							tempArr = checkCapture(i,num, dir)
							if tempArr != false
								tempArr.each do |p|
									if p.length > longestCapture
										possibleMoves.clear
										longestCapture = p.length
										temp = Array.new
										temp << "c"
										temp << i
										p.each do |q|
											temp << q
										end
										possibleMoves.add(temp)
									elsif p.length == longestCapture
										temp = Array.new
										temp << "c"
										temp << i
										p.each do |q|
											temp << q
										end
										possibleMoves.add(temp)
									end
								end 
							end
						end
					end
				else 
					n =  @board[i+9*dir]
					if n != whosTurn && n != whosTurn+2
						#empty or enemy peice there
						if n == 0
							if longestCapture == 0 #Only add regular moves if there are no captures available
								possibleMoves.add(["n",i,i+9*dir])
							end
						else
							#CAPTURE
							tempArr = checkCapture(i,9*dir, dir)
							if tempArr != false
								tempArr.each do |p|
									if p.length > longestCapture
										possibleMoves.clear
										longestCapture = p.length
										temp = Array.new
										temp << "c"
										temp << i
										p.each do |q|
											temp << q
										end
										possibleMoves.add(temp)
									elsif p.length == longestCapture
										temp = Array.new
										temp << "c"
										temp << i
										p.each do |q|
											temp << q
										end
										possibleMoves.add(temp)
									end
								end 
							end
						end
					end
					n =  @board[i+7*dir]
					if n != whosTurn && n != whosTurn+2
						#empty or enemy peice there
						if n == 0
							if longestCapture == 0 #Only add regular moves if there are no captures available
								possibleMoves.add(["n",i,i+7*dir])
							end
						else
							#CAPTURE
							tempArr = checkCapture(i,7*dir, dir)
							if tempArr != false
								tempArr.each do |p|
									if p.length > longestCapture
										possibleMoves.clear
										longestCapture = p.length
										temp = Array.new
										temp << "c"
										temp << i
										p.each do |q|
											temp << q
										end
										possibleMoves.add(temp)
									elsif p.length == longestCapture
										temp = Array.new
										temp << "c"
										temp << i
										p.each do |q|
											temp << q
										end
										possibleMoves.add(temp)
									end
								end 
							end
						end
					end
				end
			elsif q == whosTurn+2												#Kings
				if (i+1).modulo(8) == 0
					#right hand edge
					n = @board[i+7]
					if n != whosTurn && n != whosTurn+2
						#empty or enemy peice there
						if n == 0
							if longestCapture == 0 #Only add regular moves if there are no captures available
								possibleMoves.add(["n",i,i+7])
							end
						else
							tempArr = checkCapture(i,7,dir)
							if tempArr != false
								tempArr.each do |p|
									if p.length > longestCapture
										possibleMoves.clear
										longestCapture = p.length
										temp = Array.new
										temp << "c"
										temp << i
										p.each do |q|
											temp << q
										end
										possibleMoves.add(temp)
									elsif p.length == longestCapture
										temp = Array.new
										temp << "c"
										temp << i
										p.each do |q|
											temp << q
										end
										possibleMoves.add(temp)
									end
								end 
							end
						end
					end
					n = @board[i-9]
					if n != whosTurn && n != whosTurn+2
						#empty or enemy peice there
						if n == 0
							if longestCapture == 0 #Only add regular moves if there are no captures available
								possibleMoves.add(["n",i,i-9])
							end
						else
							tempArr = checkCapture(i,-9,dir)
							if tempArr != false
								tempArr.each do |p|
									if p.length > longestCapture
										possibleMoves.clear
										longestCapture = p.length
										temp = Array.new
										temp << "c"
										temp << i
										p.each do |q|
											temp << q
										end
										possibleMoves.add(temp)
									elsif p.length == longestCapture
										temp = Array.new
										temp << "c"
										temp << i
										p.each do |q|
											temp << q
										end
										possibleMoves.add(temp)
									end
								end 
							end
						end
					end
				elsif i.modulo(8) == 0
					#left hand edge
					n = @board[i-7]
					if n != whosTurn && n != whosTurn+2
						#empty or enemy peice there
						if n == 0
							if longestCapture == 0 #Only add regular moves if there are no captures available
								possibleMoves.add(["n",i,i-7])
							end
						else
							tempArr = checkCapture(i,-7,dir)
							if tempArr != false
								tempArr.each do |p|
									if p.length > longestCapture
										possibleMoves.clear
										longestCapture = p.length
										temp = Array.new
										temp << "c"
										temp << i
										p.each do |q|
											temp << q
										end
										possibleMoves.add(temp)
									elsif p.length == longestCapture
										temp = Array.new
										temp << "c"
										temp << i
										p.each do |q|
											temp << q
										end
										possibleMoves.add(temp)
									end
								end 
							end
						end
					end
					n = @board[i+9]
					if n != whosTurn && n != whosTurn+2
						#empty or enemy peice there
						if n == 0
							if longestCapture == 0 #Only add regular moves if there are no captures available
								possibleMoves.add(["n",i,i+9])
							end
						else
							tempArr = checkCapture(i,9,dir)
							if tempArr != false
								tempArr.each do |p|
									if p.length > longestCapture
										possibleMoves.clear
										longestCapture = p.length
										temp = Array.new
										temp << "c"
										temp << i
										p.each do |q|
											temp << q
										end
										possibleMoves.add(temp)
									elsif p.length == longestCapture
										temp = Array.new
										temp << "c"
										temp << i
										p.each do |q|
											temp << q
										end
										possibleMoves.add(temp)
									end
								end 
							end
						end
					end
				else
					#non-edge
					if i <= 54
						n = @board[i+9]
						if n != whosTurn && n != whosTurn+2
							if n == 0
								if longestCapture == 0
									possibleMoves.add(["n",i,i+9])
								end
							else
								tempArr = checkCapture(i,9,1)
								if tempArr != false
									tempArr.each do |p|
										if p.length > longestCapture
											possibleMoves.clear
											longestCapture = p.length
											temp = Array.new
											temp << "c"
											temp << i
											p.each do |q|
												temp << q
											end
											possibleMoves.add(temp)
										elsif p.length == longestCapture
											temp = Array.new
											temp << "c"
											temp << i
											p.each do |q|
												temp << q
											end
											possibleMoves.add(temp)
										end
									end 
								end
							end
						end
					end
					n = @board[i+7]
					if i <= 56
						if n != whosTurn && n != whosTurn+2
							if n == 0
								if longestCapture == 0
									possibleMoves.add(["n",i,i+7])
								end
							else
								#Capture
								tempArr = checkCapture(i,7,1)
								if tempArr != false
									tempArr.each do |p|
										if p.length > longestCapture
											possibleMoves.clear
											longestCapture = p.length
											temp = Array.new
											temp << "c"
											temp << i
											p.each do |q|
												temp << q
											end
											possibleMoves.add(temp)
										elsif p.length == longestCapture
											temp = Array.new
											temp << "c"
											temp << i
											p.each do |q|
												temp << q
											end
											possibleMoves.add(temp)
										end
									end 
								end
							end
						end
					end
					if i >= 9
						n = @board[i-9]
						if n != whosTurn && n != whosTurn+2
							if n == 0
								if longestCapture == 0
									possibleMoves.add(["n",i,i-9])
								end
							else
								#Capture
								tempArr = checkCapture(i,-9,-1)
								if tempArr != false
									tempArr.each do |p|
										if p.length > longestCapture
											possibleMoves.clear
											longestCapture = p.length
											temp = Array.new
											temp << "c"
											temp << i
											p.each do |q|
												temp << q
											end
											possibleMoves.add(temp)
										elsif p.length == longestCapture
											temp = Array.new
											temp << "c"
											temp << i
											p.each do |q|
												temp << q
											end
											possibleMoves.add(temp)
										end
									end 
								end
							end
						end
					end
					if i >= 7
						n = @board[i-7]
						if n != whosTurn && n != whosTurn+2
							if n == 0
								if longestCapture == 0
									possibleMoves.add(["n",i,i-7,])
								end
							else
								#Capture
								tempArr = checkCapture(i,-7,-1)
								if tempArr != false
									tempArr.each do |p|
										if p.length > longestCapture
											possibleMoves.clear
											longestCapture = p.length
											temp = Array.new
											temp << "c"
											temp << i
											p.each do |q|
												temp << q
											end
											possibleMoves.add(temp)
										elsif p.length == longestCapture
											temp = Array.new
											temp << "c"
											temp << i
											p.each do |q|
												temp << q
											end
											possibleMoves.add(temp)
										end
									end 
								end
							end
						end
					end
				end

			end
			i += 1
		end
		return possibleMoves
	end

	def makeMove(mMove)
		if mMove[0] == "n" #Non-Capture
			@board[mMove[2]] = @board[mMove[1]]
			@board[mMove[1]] = 0
		elsif mMove[0] == "c" #Capture
			whoseTurnNow = @board[mMove[1]]
			if whoseTurnNow == 1 || whoseTurnNow == 3
				@numB = @numB - (mMove.length-2)
			else
				@numW = @numW - (mMove.length-2)
			end
			@board[mMove[1]] = 0
			count = 2
			prevI = mMove[1]
			while count <= mMove.length-1
				avg = (mMove[count] + prevI)/2
				@board[avg] = 0
				prevI = mMove[count]
				count += 1
			end
			@board[mMove[mMove.length-1]] = whoseTurnNow
		end
	end

	def display
		i = 0
		print "+"
		while i < @dim
			print " -"
			i += 1
		end
		puts " +"
		i = 0
		print "| "
		@board.each do |q|
			if i == @dim
				puts "|"
				print "| "
				i = 0
			end
			if q == 0
				print ". "
			elsif q == 1
				print "w "
			elsif q == 2
				print "b "
			elsif q == 3
				print "W "
			elsif q == 4
				print "B "
			end
			i += 1
		end
		puts "|"
		i = 0
		print "+"
		while i < @dim
			print " -"
			i += 1
		end
		puts " +"
	end
end

def getMoveNumbersFromString(input)
	#split input on ->
	split = input.split("->")
	retArray = Array.new
	split.each do |q|
		if m = q.match(/\[(\d+),(\d+)\]/)
			xY = m[1].to_i*8+m[2].to_i
			retArray << xY
		else
			puts "Invalid Input"
			return
		end
	end
	
	return retArray
end

def setContainsTuple(set1, query)
	set1.each do |s1|
		counter = 1
		check = true
		query.each do |q|
			if s1[counter] != q
				check = false
			end
			counter += 1
		end
		if check
			return s1[0]
		end
	end
	return false
end

def isTerminalState(curState)
	if curState.getNumW == 0
		return 10
	end
	if curState.getNumB == 0
		return -10
	end
	return false
end

def hMiniMax(curState,depth,whoseTurn,alpha,beta)
	#If terminal state, return utility of terminal state
	tState = isTerminalState(curState)
	if tState != false
		if depth == 0
			return 0
		end
		return tState
	end

	if depth == H_MINI_MAX_DEPTH
		return curState.getNumB - curState.getNumW			#Heuristic
	end

	if whoseTurn == 2
		bestVal = -1000
		bestMove = 0
		curState.getAllMoves(2).each do |move|
			child = Marshal.load(Marshal.dump(curState)) #Deep Copy
			child.makeMove(move)
			value = hMiniMax(child, depth+1,1,alpha,beta) #Error is occuring on a secondary call of hMiniMax
			if value >= bestVal
				bestVal = value
				if depth == 0
					bestMove = move
				end
			end
			alpha = [alpha,bestVal].max
			if beta <= alpha
				break
			end
		end
	else
		bestVal = 1000
		curState.getAllMoves(1).each do |move|
			child = Marshal.load(Marshal.dump(curState)) #Deep Copy
			child.makeMove(move)
			value = hMiniMax(child,depth+1,2,alpha,beta)
			bestVal = [bestVal,value].min
			beta = [beta,bestVal].min
			if beta <= alpha
				break
			end
		end
	end
	if depth == 0
		return bestMove
	end
	return bestVal
end

initialState = State.new(8)
#Initial Checkers Board Setup#########
i = 0
d = initialState.getDim
while i < d
	initialState.putAt(0,i,2)
	initialState.putAt(1,i+1,2)
	initialState.putAt(2,i,2)

	initialState.putAt(d-1,i+1,1)
	initialState.putAt(d-2,i,1)
	initialState.putAt(d-3,i+1,1)
	i += 2
end
initialState.setNumB(12)
initialState.setNumW(12)

#############################


initialState.display
curState = initialState
whoseTurn = 1
while 0 == 0
	if whoseTurn == 1
		puts "Num Blacks: #{curState.getNumB} Num Whites: #{curState.getNumW}"

		pMoves = curState.getAllMoves(whoseTurn) # 1 is white, 2 is black
		#pMoves: [0] is 'n' for non-capture, 'c' for capture
		#        [1] is old location of peice
		#        [2] is new location of peice
		if pMoves.length == 0
			puts "No Moves Available! Game over"
			return
		end
		puts "Select your move: "
		print "=>Possible Moves: "
		puts "#{pMoves.length} possible move(s):"
		pMoves.each do |q|
			i = 0
			q.each do |r|
				if i != 0
					print "#{curState.boardGetRowCol(r)}"
				end
				if i != q.length-1 && i != 0
					print "->"
				end
				i += 1
			end
			puts ""
		end
		move = gets
		if move.chomp.eql? "q" #'q' to quit game
			return
		end

		if moveInts = getMoveNumbersFromString(move)
			r = setContainsTuple(pMoves, moveInts)
			if r != false
				#make move
				mMove = Array.new
				mMove << r
				moveInts.each do |q|
					mMove << q
				end
				curState.makeMove(mMove)
				if mMove[-1] <= 7
					curState.putAtIndex(mMove[-1],3)
				end
				whoseTurn = 2 
			else
				puts "NON-Legal move, try again. Note: Its a rule of Checkers that you make the longest possible capture available"
			end
		else
			puts "Malformed Input. Try again: [startRow,startCol]->[finishRow,finishCol]"
		end
	else
		puts "Program Making Move ........ "
		programMove = hMiniMax(initialState,0,2,1000,-1000)
		if programMove == 0
			puts "No Moves Available! Game over"
			return
		end
		i = 0
		programMove.each do |r|
			if i != 0
				print "#{curState.boardGetRowCol(r)}"
			end
			if i != programMove.length-1 && i != 0
				print "->"
			end
			i += 1
		end
		puts ""
		curState.makeMove(programMove)
		if programMove[-1] >= 56
			curState.putAtIndex(programMove[-1],4)
		end
		whoseTurn = 1 
	end

	curState.display
end



