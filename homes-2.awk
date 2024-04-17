BEGIN {
    FS=","
    OFS=FS
    print "NumberOfRooms", "AveragePrice"
}

NR > 1 {
    rooms=$4
    sellPrice=$1
    housesBySize[rooms] = housesBySize[rooms] + 1
    sellPriceSum[rooms] = sellPriceSum[rooms] + sellPrice
}

END {
    for(numOfRooms in housesBySize){
        avg = (sellPriceSum[numOfRooms] / housesBySize[numOfRooms]) * 1000
        avgFormatted = sprintf("$%.2f", avg)
        print numOfRooms, avgFormatted
    }
}