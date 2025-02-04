using HypertextLiteral, Dates, EzXML, StringEncodings

french_months = ["janvier", "février", "mars", "avril", "mai", "juin",
                 "juillet", "août", "septembre", "octobre", "novembre", "décembre"];
french_monts_abbrev = ["janv","févr","mars","avril","mai","juin",
                       "juil","août","sept","oct","nov","déc"];
french_days = ["lundi","mardi","mercredi","jeudi","vendredi","samedi","dimanche"];
Dates.LOCALES["french"] = Dates.DateLocale(french_months, french_monts_abbrev, french_days, [""]);

struct Use
    date::Date
    title::String
end

struct PrimeMinister
    name::String
    comment::String
    party::String
    asset::String
    assetsource::String
end

# You can either learn how to make EzXML decode using UTF-8, or you can fix manually.
function fixencoding(s, origin)
    decode(encode(s, EzXML.encoding(xml)), "UTF-8")
end

# All prime ministers appearing in the table and their abbreviations
ALL_PRIME_MINISTERS = Dict([
    "Pompidou" => PrimeMinister( "Georges Pompidou", "", "right", "pompidou.jpg", "https://commons.wikimedia.org/wiki/File:Georges_Pompidou_1969_(cropped).jpg")
    "Debré" => PrimeMinister( "Michel Debré", "", "right", "debre.jpg", "https://commons.wikimedia.org/wiki/File:Michel_Debr%C3%A9.jpg")
    "Barre" => PrimeMinister( "Raymond Barre", "", "right", "barre.jpg", "https://commons.wikimedia.org/wiki/File:Raymond_Barre_1980_(cropped_2).jpg")
    "Mauroy" => PrimeMinister( "Pierre Mauroy", "", "left", "mauroy.jpg", "https://commons.wikimedia.org/wiki/File:Pierre_Mauroy_1990.jpg")
    "Fabius" => PrimeMinister( "Laurent Fabius", "", "left", "fabius.jpg", "https://commons.wikimedia.org/wiki/File:Laurent_Fabius_and_Catherine_McKenna_(22913103711)_(cropped).jpg")
    "Chirac" => PrimeMinister( "Jacqus Chirac", "", "right", "chirac.jpg", "https://fr.wikipedia.org/wiki/Fichier:Jacques_Chirac_(1997)_(cropped).jpg")
    "Rocard" => PrimeMinister( "Michel Rocard", "", "left", "rocard.jpg", "https://commons.wikimedia.org/wiki/File:Michel_Rocard-IMG_3829.jpg")
    "Cresson" => PrimeMinister( "Edith Cresson", "", "left", "cresson.jpg", "https://commons.wikimedia.org/wiki/File:%C3%89dith_Cresson,_Member_of_the_EC_(1997)_(cropped).jpg")
    "Bérégovoy" => PrimeMinister( "Pierre Bérégovoy", "", "left", "beregovoy.jpg", "https://commons.wikimedia.org/wiki/File:Pierre-Beregovoy.webp")
    "Balladur" => PrimeMinister( "Édouard Balladur", "", "right", "balladur.jpg", "https://commons.wikimedia.org/wiki/File:%C3%89douard_Balladur_-_1993_(cropped).jpg")
    "Juppé" => PrimeMinister( "Alain Juppé", "", "right", "juppe.jpg", "https://commons.wikimedia.org/wiki/File:Alain_Jupp%C3%A9_%C3%A0_Qu%C3%A9bec_en_2015_(cropped_2).jpg")
    "Raffarin" => PrimeMinister( "Jean-Pierre Raffarin", "", "right", "raffarin.jpg", "https://commons.wikimedia.org/wiki/File:Jean-Pierre_Raffarin_par_Claude_Truong-Ngoc_2013_(cropped_2).jpg")
    "Villepin" => PrimeMinister( "Dominique de Villepin", "", "right", "villepin.jpg", "https://commons.wikimedia.org/wiki/File:Launch_Republique_Solidaire_2010-06-19_n05.jpg")
    "Valls" => PrimeMinister( "Manuel Valls", "", "left", "valls.jpg", "https://commons.wikimedia.org/wiki/File:Valls_Schaefer_Munich_Economic_Summit_2015_(cropped).JPG?uselang=fr")
    "Philippe" => PrimeMinister( "Édouard Philippe", "", "right", "philippe.jpg", "https://commons.wikimedia.org/wiki/File:%C3%89douard_Philippe_%C3%A0_Ch%C3%A2lons-en-Champagne_en_2023._(cropped).jpg?uselang=fr")
    "Borne" => PrimeMinister( "Élisabeth Borne", "", "center", "borne.jpg", "https://commons.wikimedia.org/wiki/File:La_Premi%C3%A8re_ministre_fran%C3%A7aise_%C3%89lisabeth_Borne_(cropped).jpg")
    "Barnier" => PrimeMinister( "Michel Barnier", "", "center", "barnier.jpg", "https://commons.wikimedia.org/w/index.php?curid=112234754")
    "Bayrou" => PrimeMinister( "François Bayrou", "", "center", "bayrou.jpg", "https://commons.wikimedia.org/wiki/File:Fran%C3%A7oisBayrou2025_(cropped).jpg")
])

DATA_URL = "https://www.assemblee-nationale.fr/dyn/decouvrir-l-assemblee/engagements-de-responsabilite-du-gouvernement-et-motions-de-censure-depuis-1958"
filename = download(DATA_URL)

# This will not use the correct encoding, will have to fix later on.
xml = readhtml(filename)
table = findfirst("//table", xml)

# Dirty trick to find the rows of interest in the table.
interesting_rows = filter(elements(table)) do element
    length(elements(element)) == 7
end

# Parsing all 49.3 uses.
all_uses = Dict{String, Vector{Use}}([
    k=>Use[] for k ∈ keys(ALL_PRIME_MINISTERS)
])
for row in interesting_rows
    nickname, reason, date, _... = nodecontent.(elements(row))

    # Fixing stuff.
    nickname = fixencoding(nickname, EzXML.encoding(xml))
    reason = fixencoding(reason, EzXML.encoding(xml))
    date = fixencoding(date, EzXML.encoding(xml))
    date = replace(date, r"\(.+\)"=>"")
    date = Date(date, "dd.mm.yyyy")

    use = Use(date, reason)
    push!(all_uses[nickname], use)
end

leaderboard = sort(collect(keys(ALL_PRIME_MINISTERS)), by = nickname->length(all_uses[nickname]), rev=true)

maxinumberofuses = length(all_uses[first(leaderboard)])

function formatdate(date)
    titlecase(Dates.format(date, "E d U Y", locale="french"))
end

function entry(nickname)
    pm = ALL_PRIME_MINISTERS[nickname]
    numberofuses = length(all_uses[nickname])
    ratio = numberofuses/maxinumberofuses
    width = 75 * ratio
    name = htl"<b>$(pm.name)</b>"
    htl"""
    <div class="entry">
    <span class="entry-bar party-$(pm.party)" style="width: $width%">$(ifelse(ratio>0.25, name, " "))<a href="$(pm.assetsource)"><img src="assets/$(pm.asset)" class="pm-picture"/></a></span> $(ifelse(ratio≤0.25, name, "")) $numberofuses emploi$(ifelse(numberofuses>1,"s",""))
      <details>
        <summary>Voir le détail</summary>
        <p>$(pm.comment)</p>
        <ul>
        $([htl"<li><b>$(formatdate(use.date))</b> : $(use.title)</li>" for use in all_uses[nickname]])          
        </ul>
      </details>
    </div>
    """
end

formatted_entries = join(entry.(leaderboard), "\n")

template = read("./template.html", String)
write(
    "index.html",
    replace(template, 
        "%%%LEADERBOARD%%%"=>string(formatted_entries),
        "%%%REGEN%%%"=>formatdate(now()) * " à " * Dates.format(now(), "HH:mm"),
    )
)

