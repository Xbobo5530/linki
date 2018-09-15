class Link {
  String url, title, imageUrl, description;
  int createdAt;

  Link(this.url, this.title, this.imageUrl, this.description, this.createdAt);

  Link.fromSnapshot(var value) {
    this.url = value['url'];
    this.title = value['title'];
    this.imageUrl = value['image_url'];
    this.description = value['description'];
    this.createdAt = value['created_at'];
  }
}
