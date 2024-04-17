BEGIN {
    FS=","
    OFS=FS
    print "SellPrice", "TaxPercent", "TaxAmount"
}

NR > 1 {
    sellPrice = $1*1000
    sellPriceString = sprintf("$%d", sellPrice)
    
    taxAmount = $9
    taxAmountString = sprintf("$%d", taxAmount)

    taxPercent = (taxAmount / sellPrice) * 100
    taxPercentString = sprintf("%.2f%%", taxPercent)
    
    print sellPriceString, taxPercentString, taxAmountString
}