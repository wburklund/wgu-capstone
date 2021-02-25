[ -r "/home/ec2-user" ] || sudo chmod -R 777 /home/ec2-user;
[ -d "~/anaconda3" ] || ln -s /home/ec2-user/anaconda3 ~/anaconda3;
[ -d "~/.dl_binaries" ] || ln -s /home/ec2-user/.dl_binaries ~/.dl_binaries;
aws s3 sync --delete s3://capstone-code-store/stage3_model_run/ ~/code;
chmod +x ~/code/run.sh;
cd ~/code; ./run.sh
