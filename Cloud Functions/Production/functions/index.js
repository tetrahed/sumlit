const functions = require('firebase-functions');
const admin = require('firebase-admin');
admin.initializeApp();

exports.processNewlyCreatedComment = functions.database.ref('/comments/{commentuuid}/{comment}').onCreate((snap, context) => {
    const commentuuid = context.params.commentuuid;
    const commentText = snap.val().comment;
    const opuuid = snap.val().useruuid;

    var reverseTimeStamp = parseInt(snap.val().timeStamp, 10) * -1;

    return admin.database().ref(snap.ref).child('reverseTimeStamp').set(reverseTimeStamp).then(res => {
        const promises = [];
        promises.push(admin.database().ref('/posts/' + commentuuid + '/commentCount').transaction(current => {
            return current + 1;
        }));

        promises.push(admin.database().ref('/posts/' + commentuuid).once('value').then(snapshot => {
            return snapshot.val().useruuid;
        }).then(useruuid => {
            return admin.database().ref('/selfPosts/' + useruuid + '/' + commentuuid + '/commentCount').transaction(current => {
                return current + 1;
            })
        }));

        promises.push(admin.database().ref('/posts/' + commentuuid).once('value').then(snapshot => {
            if (opuuid !== snapshot.val().useruuid) {
                return snapshot.val().useruuid;
            }
            return null;
        }).then(useruuid => {
            return admin.database().ref('/validUsers/' + useruuid).once('value').then(commentorsUsername => {
                return admin.database().ref('/tokens/' + useruuid).once('value').then(tokenValue => {
                    const payload = {
                        notification: {
                            title: 'Someone commented on your post',
                            body: commentorsUsername.val() + ' commented: ' + commentText
                        }
                    };

                    if (tokenValue.val() === undefined) {
                        return null
                    } else {
                        return admin.messaging().sendToDevice(tokenValue.val(), payload);
                    }
                })
            })
        }));

        return Promise.all(promises);
    }).catch(error => {
        console.log(error);
        return null;
    })
});

exports.processNewlyCreatedReplyComment = functions.database.ref('/replyComments/{postuuid}/{parentCommentuuid}/{newCommentuuid}').onCreate((snap, context) => {
    const reverseTimeStamp = parseInt(snap.val().timeStamp, 10) * -1;
    const postuuid = context.params.postuuid;
    const parentCommentuuid = context.params.parentCommentuuid;
    const replyingToUseruuid = snap.val().replyingToUseruuid;
    const opuuid = snap.val().useruuid;
    const commentText = snap.val().comment;

    return admin.database().ref(snap.ref).child('reverseTimeStamp').set(reverseTimeStamp).then(res => {
        const promises = [];
        promises.push(admin.database().ref('/posts/' + postuuid + '/commentCount').transaction(current => {
            return current + 1;
        }));

        promises.push(admin.database().ref('/posts/' + postuuid).once('value').then(snapshot => {
            return snapshot.val().useruuid;
        }).then(useruuid => {
            return admin.database().ref('/selfPosts/' + useruuid + '/' + postuuid + '/commentCount').transaction(current => {
                return current + 1;
            })
        }));

        promises.push(admin.database().ref('/comments/' + postuuid + '/' + parentCommentuuid).child('hasReplies').set(true).then(res => {
            return null;
        }));

        promises.push(admin.database().ref('/comments/' + postuuid + '/' + parentCommentuuid + '/replyCount').transaction(current => {
            return current + 1;
        }));

        promises.push(admin.database().ref('/posts/' + postuuid).once('value').then(snapshot => {
            if (opuuid !== snapshot.val().useruuid) {
                return snapshot.val().useruuid;
            }
            return null;
        }).then(useruuid => {
            return admin.database().ref('/validUsers/' + useruuid).once('value').then(commentorsUsername => {
                return admin.database().ref('/tokens/' + useruuid).once('value').then(tokenValue => {
                    const payload = {
                        notification: {
                            title: 'Someone commented on your post',
                            body: commentorsUsername.val() + ' commented: ' + commentText
                        }
                    };

                    if (tokenValue.val() === undefined) {
                        return null
                    } else {
                        return admin.messaging().sendToDevice(tokenValue.val(), payload);
                    }
                })
            })
        }));

        return Promise.all(promises);
    }).catch(error => {
        console.log(error);
        return null;
    })
});

exports.processNewlyCreatedPostVote = functions.database.ref('/postVote/{postuuid}').onCreate((snap, context) => {
    const postersuuid = snap.val().postersuuid;
    return admin.database().ref('/credits/' + postersuuid + '/creditsCount').transaction(current => {
        return current + 1;
    })
});

exports.processPostVoteUpdate = functions.database.ref('/postVote/{postuuid}').onUpdate((change, context) => {
    const postersuuid = change.after.val().postersuuid;
    const beforeUpvotes = change.before.val().upvotes;
    const afterUpvotes = change.after.val().upvotes;

    if (beforeUpvotes === afterUpvotes) {
        return null;
    } else if (beforeUpvotes < afterUpvotes) {
        const addedValue = afterUpvotes - beforeUpvotes;
        return admin.database().ref('/credits/' + postersuuid + '/creditsCount').transaction(current => {
            return current + addedValue;
        });
    } else {
        const subtractedValue = beforeUpvotes - afterUpvotes;
        return admin.database().ref('/credits/' + postersuuid + '/creditsCount').transaction(current => {
            return current - subtractedValue;
        });
    }
});

exports.processPostVoteNotificationUpdate = functions.database.ref('/postVote/{postuuid}').onUpdate((change, context) => {
    const postersuuid = change.after.val().postersuuid;
    const beforeUpvotes = change.before.val().upvotes;
    const afterUpvotes = change.after.val().upvotes;
    const postuuid = context.params.postuuid;
    const lastUpvoteruuid = change.after.val().lastUpvoteruuid;

    if (beforeUpvotes < afterUpvotes) {
        if (lastUpvoteruuid !== postersuuid) {
            console.log("Poster");
            return admin.database().ref('/postVoteHistory/' + postuuid + '/' + lastUpvoteruuid).once('value').then(history => {
                if (!history.exists()) {
                    console.log("Does not exist")
                    return admin.database().ref('/postVoteHistory/' + postuuid + '/' + lastUpvoteruuid).set(true).then(something => {
                        return admin.database().ref('/tokens/' + postersuuid).once('value').then(tokenValue => {
                            const payload = {
                                notification: {
                                    title: 'Someone upvoted your post',
                                    body: "Your post now has " + afterUpvotes + " upvotes!"
                                }
                            };

                            if (tokenValue.val() === undefined) {
                                console.log("Token undefined.");
                                return null;
                            } else {
                                console.log("Sending notification");
                                return admin.messaging().sendToDevice(tokenValue.val(), payload);
                            }
                        })
                    })
                } else {
                    return null;
                }
            })
        }
    }
    return null;
});

exports.processPostVoteDeletion = functions.database.ref('/postVote/{postuuid}').onDelete((snap, context) => {
    const postersuuid = snap.val().postersuuid;
    const upvotes = parseInt(snap.val().upvotes);
    return admin.database().ref('/credits/' + postersuuid + '/creditsCount').transaction(current => {
        return current - upvotes;
    });
});

exports.processCommentUpvoteCountUpdate = functions.database.ref('/comments/{postuuid}/{commentuuid}').onUpdate((change, context) => {
    const prevValue = parseInt(change.before.val().upvotes);
    const newValue = parseInt(change.after.val().upvotes);
    const commentersuuid = change.after.val().useruuid;
    const wasDeleted = change.after.val().wasDeleted;

    if (wasDeleted === undefined) {
        if (prevValue === newValue) {
            console.log('There was no change.');
            return null;
        } else if (prevValue < newValue) {
            console.log("Comment was upvoted.");
            const addedValue = newValue - prevValue;
            return admin.database().ref('/credits/' + commentersuuid + '/creditsCount').transaction(current => {
                return current + addedValue;
            });
        } else {
            console.log('Comment was downvoted.');
            const subtractedValue = prevValue - newValue;
            return admin.database().ref('/credits/' + commentersuuid + '/creditsCount').transaction(current => {
                return current - subtractedValue;
            });
        }
    } else {
        console.log("Comment was deleted so can't do anything here." + wasDeleted);
        return null;
    }
});

exports.processCommentDeletedUpdate = functions.database.ref('/comments/{postuuid}/{commentuuid}/wasDeleted').onCreate((snap, context) => {
    console.log("In processCommentDeletedUpdate");

    return admin.database().ref(snap.ref.parent).once('value').then(snapshot => {
        const commentersuuid = snapshot.val().useruuid;
        const downvoteValue = parseInt(snapshot.val().upvotes);
        return admin.database().ref('/credits/' + commentersuuid + '/creditsCount').transaction(current => {
            return current - downvoteValue;
        });
    })
});

exports.processReplyCommentUpvoteCountUpdate = functions.database.ref('/replyComments/{postuuid}/{parentCommentuuid}/{commentuuid}').onUpdate((change, context) => {
    console.log("In processReplyCommentUpvoteCountUpdate");
    const prevValue = parseInt(change.before.val().upvotes);
    const newValue = parseInt(change.after.val().upvotes);
    const commentersuuid = change.after.val().useruuid;
    const wasDeleted = change.after.val().wasDeleted;

    if (wasDeleted === undefined) {

        if (prevValue === newValue) {
            console.log('There was no change.');
            return null;
        } else if (prevValue < newValue) {
            console.log("Comment was upvoted.");
            const addedValue = newValue - prevValue;
            return admin.database().ref('/credits/' + commentersuuid + '/creditsCount').transaction(current => {
                return current + addedValue;
            });
        } else {
            console.log('Comment was downvoted.');
            const subtractedValue = prevValue - newValue;
            return admin.database().ref('/credits/' + commentersuuid + '/creditsCount').transaction(current => {
                return current - subtractedValue;
            });
        }
    } else {
        console.log("Comment was deleted so can't do anything here." + wasDeleted);
        return null;
    }
});

exports.processReplyCommentDeletedUpdate = functions.database.ref('/replyComments/{postuuid}/{parentCommentuuid}/{commentuuid}/wasDeleted').onCreate((snap, context) => {
    console.log("In processReplyCommentDeletedUpdate");

    return admin.database().ref(snap.ref.parent).once('value').then(snapshot => {
        const commentersuuid = snapshot.val().useruuid;
        const downvoteValue = parseInt(snapshot.val().upvotes);
        return admin.database().ref('/credits/' + commentersuuid + '/creditsCount').transaction(current => {
            return current - downvoteValue;
        });
    })
});

exports.processNewlyCreatedUser = functions.database.ref('validUsers/{useruuid}').onCreate((snap, context) => {
    const useruuid = context.params.useruuid;
    return admin.database().ref('/credits/' + useruuid + "/creditsCount").set(0);
});