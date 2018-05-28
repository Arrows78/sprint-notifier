require "erb"
require "date"
require 'pathname'

$tickets_list = []

email_body = {
    title: "Career Services Sprint Update",
    sprint_end_date: "#{(Time.now).strftime("%B")} #{Time.now.day}, #{Time.now.year}",
    edito: "“Hi everybody,<br>This week, we'll have Sacha, Vlatka and Emmanuel working on the sprint.<br>Have a nice day !“<br /><br /><em>Thomas and Laurent</em>",
    witty_comment: "Delivery Jost-in-Time",
    first_section: {
        title: "Tickets delivered during last sprint",
        statuses: ['DONE'],
        file: 'last_sprint.txt',
        new_features: {
            type: "New Feature",
            nb_tickets: 0,
            tickets: []
        },
        improvements: {
            type: "Improvement",
            nb_tickets: 0,
            tickets: []
        },
        tasks: {
            type: "Task",
            nb_tickets: 0,
            tickets: []
        },
        bugs: {
            type: "Bug",
            nb_tickets: 0,
            tickets: []
        },
    },
    second_section: {
        title: "Tickets not delivered during last sprint <br />(will be transferred to next sprint)",
        statuses: ['TO DO', 'IN DEV', 'TECH REVIEW', 'FUNCTIONAL REVIEW', 'READY FOR RELEASE'],
        file: 'last_sprint.txt',
        new_features: {
            type: "New Feature",
            nb_tickets: 0,
            tickets: []
        },
        improvements: {
            type: "Improvement",
            nb_tickets: 0,
            tickets: []
        },
        tasks: {
            type: "Task",
            nb_tickets: 0,
            tickets: []
        },
        bugs: {
            type: "Bug",
            nb_tickets: 0,
            tickets: []
        },
    },
    third_section: {
        title: "Other tickets planned for next sprint",
        statuses: ['TO DO', 'IN DEV', 'TECH REVIEW', 'FUNCTIONAL REVIEW', 'READY FOR RELEASE'],
        file: 'next_sprint.txt',
        new_features: {
            type: "New Feature",
            nb_tickets: 0,
            tickets: []
        },
        improvements: {
            type: "Improvement",
            nb_tickets: 0,
            tickets: []
        },
        tasks: {
            type: "Task",
            nb_tickets: 0,
            tickets: []
        },
        bugs: {
            type: "Bug",
            nb_tickets: 0,
            tickets: []
        }
    }
}

################################################################################################ FUNCTIONS SECTION

###############################################################################################
# FUNCTION: section_looper
# 
# PURPOSE: Iterate the process on all sections
# 
# PARAMETERS:
#       email_body: Get content of the email to generate
#
# RETURNS:  /
################################################################################################
def section_looper(email_body)
    section = [:first_section, :second_section, :third_section]

    section.each do |section|
        type_looper(email_body, section)
    end
end

###############################################################################################
# FUNCTION: type_looper
# 
# PURPOSE: Itearate the process on all type of tickets
# 
# PARAMETERS:
#       email_body: Get content of the email to generate
#       section: Current section to iterate on
#
# RETURNS:  /
################################################################################################
def type_looper(email_body, section)
    type = [:new_features, :improvements, :tasks, :bugs]
    
    type.each do |cType|
        tickets_looper(email_body, section, email_body[section][cType][:type], email_body[section][:file], email_body[section][:statuses], email_body[section][cType][:tickets], email_body[section][cType])
    end
end

###############################################################################################
# FUNCTION: tickets_looper
# 
# PURPOSE: Iterate on all lines of sprint files (last and next sprints)
# 
# PARAMETERS:
#       email_body: Get content of the email to generate
#       section: Current section to iterate on
#       type: ?
#       file: ?
#       statuses: ?
#       tickets: ?
#       ticket_details: ?
#
# RETURNS:  /
################################################################################################
def tickets_looper(email_body, section, type, file, statuses, tickets, ticket_details)
    i = 0

    File.open(file).readlines.each do |cLine|
        # Check if the file has been added
        if cLine.include?(type) && statuses.inject(false) { |memo, status| cLine.downcase.include?(status.downcase) || memo }
            unless $tickets_list.include?(cLine.split("\t")[1])
                tickets << cLine.split("\t")[1]
                i = i + 1
            end
        end
    end

    if i > 0
        $tickets_list = tickets + ($tickets_list - tickets)
        ticket_details[:nb_tickets] = i
    end
end

###############################################################################################
# FUNCTION: pluralize
# 
# PURPOSE: Add the pluralize
# 
# PARAMETERS:
#       word: The word to check if we need to add plural of not
#       nb: Number to identify plural
#
# RETURNS:  Current string with adjustment on plural word
################################################################################################
def pluralize(word, nb)
    if (nb > 1)
        return "#{word}s"
    else
        return "#{word}"
    end
end

###############################################################################################
# FUNCTION: getfilename
# 
# PURPOSE:  Determine the filename with current date
# 
# PARAMETERS: /
# 
# RETURNS:  Path of the file to create serving to add all information of the sprint update
################################################################################################
def getfilename()
    current_time = Time.new.strftime("%Y-%m-%d")
    
    # Create filename
    filename = 'sprint_update_' + current_time + ".html"

    # Create folder with all file of sprint update
    foldername = "History"
    Dir.mkdir(foldername) unless File.exists?(foldername)

    return File.join(".", foldername, filename)
end


################################################################################################ MAIN SECTION

section_looper(email_body)
puts email_body

@email_body = email_body

# Render template
template = File.read('./template.html.erb')
result = ERB.new(template).result(binding)

# Write result to file
filename = getfilename()
File.open(filename, 'w+') do |f|
    f.write result
end
