class Link {
  String id, url, title, imageUrl, description;
  int createdAt;

  Link(this.id, this.url, this.title, this.imageUrl, this.description,
      this.createdAt);

  /// a constructor for converting the snapshot to a dart object
  Link.fromSnapshot(var value) {
    this.url = value['url'];
    this.title = value['title'];
    this.imageUrl = value['image_url'];
    this.description = value['description'];
    this.createdAt = value['created_at'];
  }
}
