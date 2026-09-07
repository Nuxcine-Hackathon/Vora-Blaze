/// Répliques locales de Vora — aucune clé réseau, revue d'équipe possible.
enum VoraGuideScene {
  splash,
  onboarding,
  login,
  signup,
  home,
  destination,
  estimate,
  searching,
  ride,
  history,
  profile,
  chat,
}

class VoraGuideLine {
  const VoraGuideLine({
    required this.spoken,
    required this.bubble,
    required this.screenLabel,
  });

  final String spoken;
  final String bubble;
  final String screenLabel;
}

class VoraGuideScript {
  static const Map<VoraGuideScene, VoraGuideLine> lines = {
    VoraGuideScene.splash: VoraGuideLine(
      screenLabel: "Splash",
      bubble: "Bienvenue. Je suis Vora.",
      spoken:
          "Bienvenue sur Vora. Je suis votre guide. Je reste avec vous pendant tout le trajet.",
    ),
    VoraGuideScene.onboarding: VoraGuideLine(
      screenLabel: "Onboarding",
      bubble: "Des courses sûres, même hors ligne un moment.",
      spoken:
          "Ici, on réserve sans stress. Je vous guide, même si la connexion est instable.",
    ),
    VoraGuideScene.login: VoraGuideLine(
      screenLabel: "Connexion",
      bubble: "Bon retour. Entrez votre numéro.",
      spoken:
          "Bon retour. Entrez votre numéro. Si vous bloquez, touchez-moi.",
    ),
    VoraGuideScene.signup: VoraGuideLine(
      screenLabel: "Inscription",
      bubble: "Je vous aide à créer votre compte.",
      spoken:
          "Créons votre compte ensemble. Vos informations restent protégées.",
    ),
    VoraGuideScene.home: VoraGuideLine(
      screenLabel: "Accueil",
      bubble: "Où allez-vous aujourd'hui ?",
      spoken:
          "Où allez-vous aujourd'hui ? Touchez-moi à tout moment si vous avez besoin d'aide.",
    ),
    VoraGuideScene.destination: VoraGuideLine(
      screenLabel: "Destination",
      bubble: "Un quartier ou un repère suffit.",
      spoken:
          "Indiquez un quartier ou un repère, par exemple un carrefour connu. Pas besoin d'une adresse exacte.",
    ),
    VoraGuideScene.estimate: VoraGuideLine(
      screenLabel: "Estimation",
      bubble: "Moto ou voiture, selon le trafic.",
      spoken:
          "Je compare moto et voiture selon le trafic, le budget et la route.",
    ),
    VoraGuideScene.searching: VoraGuideLine(
      screenLabel: "Recherche chauffeur",
      bubble: "Je cherche un chauffeur vérifié.",
      spoken:
          "Je cherche un chauffeur vérifié près de vous. Restez serein, je suis là.",
    ),
    VoraGuideScene.ride: VoraGuideLine(
      screenLabel: "Course en cours",
      bubble: "Course suivie. SOS si besoin.",
      spoken:
          "Votre course est suivie. En cas de souci, touchez-moi ou le bouton d'urgence.",
    ),
    VoraGuideScene.history: VoraGuideLine(
      screenLabel: "Historique",
      bubble: "Vos trajets et reçus sont ici.",
      spoken: "Retrouvez ici vos trajets, vos reçus et vos évaluations.",
    ),
    VoraGuideScene.profile: VoraGuideLine(
      screenLabel: "Profil",
      bubble: "Vos données restent protégées.",
      spoken:
          "Vos informations restent protégées. Je peux vous expliquer chaque réglage.",
    ),
    VoraGuideScene.chat: VoraGuideLine(
      screenLabel: "Assistant",
      bubble: "Posez-moi une question.",
      spoken:
          "Je suis Vora. Posez-moi une question sur une course, Mobile Money, la sécurité ou un quartier.",
    ),
  };

  static VoraGuideLine of(VoraGuideScene scene) => lines[scene]!;
}
