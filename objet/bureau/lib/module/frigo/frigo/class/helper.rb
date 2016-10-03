# encoding: UTF-8
class Frigo
class << self

  # Formulaire pour se logguer si l'on est un interlocuteur ou pour
  # s'enregistrer pour la première fois sur un fil.
  def form_login_signup_quidam
    (
      explication_login_signup.in_div(class:'tiny') +
      'create_of_retreive_discussion'.in_hidden(name:'operation') +
      (param(:qpseudo)||'').in_input_text(name:'qpseudo', placeholder: 'Votre pseudo', style: 'width:400px').in_div +
      (param(:qmail)||'').in_input_text(name:'qmail', placeholder: 'Votre mail', style: 'width:400px').in_div +
      explication_mail.in_div(class: 'tiny') +
      (''.in_password(name: 'qpassword', placeholder: 'Code secret') + ' (au moins 6 caractères)'.in_span(class: 'tiny')).in_div +
      app.fields_captcha +
      'OK'.in_submit(class:'btn tiny').in_div(class: 'buttons')
    ).in_form(id:'form_login_quidam', class: 'mg dix', action: "bureau/#{frigo.owner_id}/frigo")
  end

  def explication_login_signup
    <<-HTML
<p>Merci de vous identifier <strong>si vous êtes icarienne ou icarien</strong>.</p>
<p>Dans le cas contraire, merci d'<strong>indiquer votre mail et le mot de passe</strong> choisi pour entamer ou poursuivre la discussion avec #{frigo.owner.pseudo}.
</p>
<p>Notez que vous devez vous inscrire <strong>pour chaque discussion</strong> que vous entamez.</p>
    HTML
  end

  def explication_mail
    <<-HTML
Notez que votre mail sera enregistré de façon cryptée et donc inutilisable dans un autre cadre que ces discussions.
    HTML
  end

end #/<< self
end #/ Frigo
