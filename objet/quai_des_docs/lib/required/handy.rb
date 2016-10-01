# encoding: UTF-8

# Retourne soit l'année courante
def annee_courante

end
# Le trimestre courant de 1 à 4
# Soit le trimestre d'aujourd'hui, soit le trimestre défini par
# le paramètre `tri`
def trimestre_courant
  @trimestre_courant ||= begin
    param(:tri) || trimestre_of_time
  end
end

# Reçoit un temps (soit {Time}, soit un nombre de secondes) et retourne
# l'index 1-start du trimestre correspondant
def trimestre_of_time time = nil
  time != nil || time = Time.now
  time.instance_of?(Fixnum) && time = Time.at(time)
  1 + ((time.month - 1)/ 3)
end

# Inverse de la précédente, reçoit une année et un trimestre et
# retourne le {Time} correspondant (début du trimestre)
def start_of_trimestre annee, trimestre

end
# Retourne le temps de la fin du trimestre, en secondes
def end_of_trimestre annee, trimestre

end
