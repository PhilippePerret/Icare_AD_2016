# encoding: UTF-8
=begin
Schéma de la table contenant les tickets
=end
def schema_table_actualites
  <<-MYSQL
CREATE TABLE actualites
  (
    id          INTEGER AUTO_INCREMENT,

    #  USER_ID
    # ---------
    # Pour information seulement, l'identifiant de l'user
    # concerné par l'actualité.
    user_id     INTEGER,

    # MESSAGE
    # -------
    # Le texte du message de l'actualité, entièrement mis en forme
    message     TEXT,

    #  DATA
    # ------
    # Des données éventuellement pour l'actualité. Le mieux est
    # que ce soit un Hash jsonné.
    data        BLOB,

    created_at  INTEGER(10),
    updated_at  INTEGER(10),
    PRIMARY KEY (id)
  );
  MYSQL
end
