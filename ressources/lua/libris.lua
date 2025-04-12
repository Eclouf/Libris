-- libris.lua
local libris = {}

-- Fonction de traitement de texte avec gestion des erreurs
function libris.traiterTexte(texte)
    if not texte then return {} end
    
    local lignes = {}
    for ligne in texte:gmatch("[^\n\r]*") do
        if ligne:match("%S") then  -- Ignore les lignes vides
            table.insert(lignes, ligne)
        end
    end
    tex.print(table.concat(lignes, "\\newline "))
end

function libris.firstchar(texte)
    if not texte then return "" end
    local str = texte

    -- Extraire le premier caractère
    local firstChar = unicode.utf8.sub(str, 1, 1)
    
    -- Extraire le premier mot sans le premier caractère
    local _, finPremierMot = str:find("^%S+")
    local word = ""
    local reste = ""
    
    if finPremierMot then
        local premierMot = str:sub(2, finPremierMot) -- Premier mot sans le premier caractère
        
        -- Chercher le deuxième mot
        local debutDeuxiemeMot = str:find("%S+", finPremierMot + 1)
        if debutDeuxiemeMot then
            local _, finDeuxiemeMot = str:find("%S+", debutDeuxiemeMot)
            local deuxiemeMot = str:sub(debutDeuxiemeMot, finDeuxiemeMot)
            
            -- Si le premier mot a 2 ou 3 caractères, inclure le deuxième mot
            if unicode.utf8.len(premierMot) <= 2 then
                word = premierMot .. " " .. deuxiemeMot
                reste = str:sub(finDeuxiemeMot + 1)
            else
                word = premierMot
                reste = str:sub(finPremierMot + 1)
            end
        else
            word = premierMot
            reste = ""
        end
    end

    -- Changer les symboles dans le reste du texte
    reste = libris.changerSymboles(reste)

    tex.sprint("\\lettrine{\\initial\\textcolor{\\initialcolor}{" .. firstChar .. "}}{" .. word .. "}{" .. reste .. "}")
end

-- Fonction de changement de symboles avec plus d'options
function libris.changerSymboles(texte)
    if not texte then return "" end
    
    local symboles = {
        ["+"] = "\\GreDagger",
        ["*"] = "\\GreStar"
    }
    
    return string.gsub(texte, "[+*#@|VR]", symboles)
end

-- Extraire le titre d'un fichier
function libris.extractTitre(nom_fichier)
    if not nom_fichier then return "" end
    
    local titre = string.match(nom_fichier, "^([^-]+)")
    return titre or nom_fichier
end

-- Fontion debut de ligne
function libris.startligne(ligne_debut, chemin)
    local ligne_debut = tonumber(ligne_debut)
    local chemin = kpse.find_file(chemin .. ".tex", "tex")
    
    if not chemin then
        tex.print("\\textbf{Erreur}: Fichier '" .. chemin .. ".tex' non trouvé!")
        return
    end
    
    local f = io.open(chemin, "r")
    local compteur = 0
    local lines = {}
    
    for line in f:lines() do
        compteur = compteur + 1
        if compteur >= ligne_debut then
            table.insert(lines, line)
        end
    end
    
    f:close()
    tex.print(lines)
end
return libris