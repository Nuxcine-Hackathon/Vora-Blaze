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
    this.videoAsset,
  });

  final String spoken;
  final String bubble;
  final String screenLabel;

  /// Clip local de l'assistante. Si présent, on joue la vidéo à la place du TTS.
  final String? videoAsset;
}

class VoraGuideScript {
  static const Map<VoraGuideScene, VoraGuideLine> lines = {
    VoraGuideScene.splash: VoraGuideLine(
      screenLabel: "Splash",
      bubble: "Salut, je suis VORA.",
      spoken: "Salut, je suis VORA et je vais te guider.",
      videoAsset: "assets/videos/vora_guide.mp4",
    ),
    VoraGuideScene.onboarding: VoraGuideLine(
      screenLabel: "Onboarding",
      bubble: "Je vais te guider.",
      spoken: "Salut, je suis VORA et je vais te guider.",
      videoAsset: "assets/videos/vora_guide.mp4",
    ),
    VoraGuideScene.login: VoraGuideLine(
      screenLabel: "Connexion",
      bubble: "Bon retour. Entrez votre numéro.",
      spoken:
          "Bon retour. Entrez votre numéro. Si vous bloquez, touchez-moi.",
    ),
    VoraGuideScene.signup: VoraGuideLine(
      screenLabel: "Inscription",
      bubble: "Inscris-toi, je veux mieux te connaître.",
      spoken: "Je veux mieux te connaître, inscris-toi.",
      videoAsset: "assets/videos/vora_signup.mp4",
    ),
    VoraGuideScene.home: VoraGuideLine(
      screenLabel: "Accueil",
      bubble: "Où veux-tu aller aujourd'hui ?",
      spoken: "Où veux-tu aller aujourd'hui ?",
      videoAsset: "assets/videos/vora_home.mp4",
    ),
    VoraGuideScene.destination: VoraGuideLine(
      screenLabel: "Destination",
      bubble: "Un quartier ou un repère suffit.",
      spoken:
          "Indiquez un quartier ou un repère, par exemple un carrefour connu. Pas besoin d'une adresse exacte.",
    ),
    VoraGuideScene.estimate: VoraGuideLine(
      screenLabel: "Estimation",
      bubble: "Le prix affiché est garanti.",
      spoken: "Le prix affiché est garanti, même en cas de trafic.",
      videoAsset: "assets/videos/vora_estimate.mp4",
    ),
    VoraGuideScene.searching: VoraGuideLine(
      screenLabel: "Recherche chauffeur",
      bubble: "Je cherche le chauffeur le plus proche.",
      spoken: "Je cherche le chauffeur le plus proche pour toi.",
      videoAsset: "assets/videos/vora_searching.mp4",
    ),
    VoraGuideScene.ride: VoraGuideLine(
      screenLabel: "Course en cours",
      bubble: "Ton chauffeur arrive. SOS toujours là.",
      spoken:
          "Ton chauffeur arrive dans quelques minutes. Le bouton SOS est toujours là.",
      videoAsset: "assets/videos/vora_ride.mp4",
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
