BEGIN {
    some_string="1"
    some_number=1

    string_plus_string = some_string + "ABC"
    string_plus_number = some_string + some_number
    number_plus_number = some_number + 1

    print "string_plus_string=" string_plus_string
    print "string_plus_number=" string_plus_number
    print "number_plus_number=" number_plus_number
}
