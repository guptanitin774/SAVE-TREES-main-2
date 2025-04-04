class CaseTileModel {
        final bool isAnonymous;
        final bool isUpdate;
        final List<double> location;
        final List<String> mightBeCutReason;
        final int mightBeCut;
        final int beenCut;
        final int haveBeenCut;
        final List photos;
        final String id;
        final String locationName;
        final int caseId;
        final String caseIdentifier;
        final dynamic addedBy;
        final String createdDate;
        final String description;
        final String state;
        final String country;
        final String city;
        final dynamic distance;
        final int watchCount;
        final int commentCount;
        final int reportCount;

        CaseTileModel({
          required this.isAnonymous,
          required this.isUpdate,
          required this.location,
          required this.mightBeCutReason,
          required this.mightBeCut,
          required this.beenCut,
          required this.haveBeenCut,
          required this.photos,
          required this.id,
          required this.locationName,
          required this.caseId,
          required this.caseIdentifier,
          required this.addedBy,
          required this.createdDate,
          required this.description,
          required this.state,
          required this.country,
          required this.city,
          required this.distance,
          required this.watchCount,
          required this.commentCount,
          required this.reportCount,
        });

        factory CaseTileModel.fromJson(Map<String, dynamic> json) {
          return CaseTileModel(
            isAnonymous: json['isanonymous'] ?? false,
            isUpdate: json['isupdate'] ?? false,
            location: List<double>.from(json['location'] ?? []),
            mightBeCutReason: List<String>.from(json['mightbecutreason'] ?? []),
            mightBeCut: json['mightbecut'] ?? 0,
            beenCut: json['beencut'] ?? 0,
            haveBeenCut: json['havebeencut'] ?? 0,
            photos: json['photos'] ?? [],
            id: json['_id'] ?? '',
            locationName: json['locationname'] ?? '',
            caseId: json['caseid'] ?? 0,
            caseIdentifier: json['caseidentifier'] ?? '',
            addedBy: json['addedby'],
            createdDate: json['createddate'] ?? '',
            description: json['description'] ?? '',
            state: json['state'] ?? '',
            country: json['country'] ?? '',
            city: json['city'] ?? '',
            distance: json['distance'],
            watchCount: json['watchcount'] ?? 0,
            commentCount: json['commentcount'] ?? 0,
            reportCount: json['reportcount'] ?? 0,
          );
        }
      }