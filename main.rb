require "erb"
require "date"
require "pathname"

# Global array to store processed tickets
$tickets_list = []

# Email body configuration
$email_body = {
    title: "Career Services Sprint Update",
    sprint_end_date: "#{(Time.now).strftime("%B")} #{Time.now.day}, #{Time.now.year}",
    edito: "“Hi everybody,<br>This week, we'll have Aurélie, Erik, Florent, Renaud, Sacha and Vlatka working on the sprint.<br>Have a nice day!“<br /><br /><em>Thomas, Morgane and Laurent</em>",
    witty_comment: "Why don't you ever see Father Christmas in hospital? - Because he has private elf care!",
    summary_section: {
        title: "Summary of the last sprint"
    },
    sections: [
        {
            title: "Tickets delivered during last sprint",
            statuses: ['DONE'],
            file: 'last_sprint.txt',
            types: ["New Feature", "Improvement", "Task", "Bug"]
        },
        {
            title: "Tickets not delivered during last sprint (will be transferred to next sprint)",
            statuses: ['TO DO', 'IN DEV', 'TECH REVIEW', 'FUNCTIONAL REVIEW', 'FUNCTIONAL GO'],
            file: 'last_sprint.txt',
            types: ["New Feature", "Improvement", "Task", "Bug"]
        },
        {
            title: "Other tickets planned for next sprint",
            statuses: ['TO DO', 'IN DEV', 'TECH REVIEW', 'FUNCTIONAL REVIEW', 'FUNCTIONAL GO'],
            file: 'next_sprint.txt',
            types: ["New Feature", "Improvement", "Task", "Bug"]
        }
    ]
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
    email_body[:sections].each do |section|
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
    section[:types].each do |ticket_type|
        tickets_looper(email_body, section, ticket_type)
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
#       ticket_type: The type of issue for a specific ticket
#
# RETURNS:  /
################################################################################################
def tickets_looper(email_body, section, ticket_type)
    tickets = []

    File.open(section[:file]).readlines.each do |line|
        # Check if the file has been added
        if line.include?(ticket_type) && section[:statuses].any? { |status| line.downcase.include?(status.downcase) }
            ticket_id = line.split("\t")[1]
            ticket_status = line.split("\t")[4]
            next if $tickets_list.include?(ticket_id) || $tickets_list.include?(ticket_id + " <span style='color: #FF6A77'>⇨ " + ticket_status + "</span>")

            # Add ticket to the list, with style applied for status
            ticket_with_status = ticket_status.downcase == "done" ? ticket_id : ticket_id + " <span style='color: #FF6A77'>⇨ " + ticket_status + "</span>"
            tickets << ticket_with_status
            $tickets_list << ticket_with_status
        end
    end

    # Update the number of tickets
    email_body[:sections].each do |sec|
        if sec[:title] == section[:title]
            section[ticket_type.downcase.tr(" ", "_").to_sym] = tickets
            section["nb_#{ticket_type.downcase.tr(" ", "_")}"] = tickets.size
        end
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
    filename = current_time + "_sprint_update_CS.html"
    foldername = "History"
    Dir.mkdir(foldername) unless File.exist?(foldername)

    return File.join(".", foldername, filename)
end


################################################################################################ MAIN SECTION

section_looper($email_body)
puts $email_body

@email_body = $email_body

# Helper to get the count of a type in a section
def count_tickets_for_type(section, type)
  key = "nb_#{type.downcase.tr(" ", "_")}"
  section[key] || 0
end

done_section = $email_body[:sections][0]
inprogress_section = $email_body[:sections][1]
todo_section = $email_body[:sections][2]

@nb_features_done        = count_tickets_for_type(done_section, "New Feature")
@nb_improvements_done    = count_tickets_for_type(done_section, "Improvement")
@nb_tasks_done           = count_tickets_for_type(done_section, "Task")
@nb_bugs_done            = count_tickets_for_type(done_section, "Bug")

@nb_features_inprogress  = count_tickets_for_type(inprogress_section, "New Feature")
@nb_improvements_inprogress = count_tickets_for_type(inprogress_section, "Improvement")
@nb_tasks_inprogress     = count_tickets_for_type(inprogress_section, "Task")
@nb_bugs_inprogress      = count_tickets_for_type(inprogress_section, "Bug")

@nb_features_todo        = count_tickets_for_type(todo_section, "New Feature")
@nb_improvements_todo    = count_tickets_for_type(todo_section, "Improvement")
@nb_tasks_todo           = count_tickets_for_type(todo_section, "Task")
@nb_bugs_todo            = count_tickets_for_type(todo_section, "Bug")

@nb_done      = @nb_features_done + @nb_improvements_done + @nb_tasks_done + @nb_bugs_done
@nb_inprogress = @nb_features_inprogress + @nb_improvements_inprogress + @nb_tasks_inprogress + @nb_bugs_inprogress
@nb_todo      = @nb_features_todo + @nb_improvements_todo + @nb_tasks_todo + @nb_bugs_todo

puts "--- Résumé des tickets ---"

puts "✔️ Done"
puts "  New Features       : #{@nb_features_done}"
puts "  Improvements       : #{@nb_improvements_done}"
puts "  Tasks              : #{@nb_tasks_done}"
puts "  Bugs               : #{@nb_bugs_done}"
puts "  Total              : #{@nb_done}"

puts "🚧 In Progress"
puts "  New Features       : #{@nb_features_inprogress}"
puts "  Improvements       : #{@nb_improvements_inprogress}"
puts "  Tasks              : #{@nb_tasks_inprogress}"
puts "  Bugs               : #{@nb_bugs_inprogress}"
puts "  Total              : #{@nb_inprogress}"

puts "📝 To Do"
puts "  New Features       : #{@nb_features_todo}"
puts "  Improvements       : #{@nb_improvements_todo}"
puts "  Tasks              : #{@nb_tasks_todo}"
puts "  Bugs               : #{@nb_bugs_todo}"
puts "  Total              : #{@nb_todo}"

# Render template
template = File.read('./template.html.erb')
result = ERB.new(template).result(binding)

# Write result to file
filename = getfilename()
File.open(filename, 'w+') do |f|
    f.write result
end

puts "Email content has been generated successfully and saved to #{filename}."
