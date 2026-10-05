#!/usr/bin/env python3
import http.server,pathlib,argparse
parser=argparse.ArgumentParser();parser.add_argument('--port',type=int,default=4173);parser.add_argument('--firebase',action='store_true');args=parser.parse_args()
root=pathlib.Path(__file__).resolve().parents[1]
class Preview(http.server.SimpleHTTPRequestHandler):
 def translate_path(self,path):
  route=path.split('?',1)[0]
  dashboard=route=='/admin' or route.startswith('/admin/')
  preview=root/'.preview'/('firebase' if args.firebase else 'local')/('dashboard' if dashboard else 'portfolio')
  base=preview if (preview/'index.html').exists() else root/('apps/dashboard/build/web' if dashboard else 'apps/portfolio/build/web')
  suffix=route.removeprefix('/admin') if dashboard else route
  # Reject path traversal; serve only the two generated web output directories.
  requested=(base/suffix.lstrip('/')).resolve()
  if not requested.is_relative_to(base.resolve()):return str(base/'not-found')
  if requested.is_dir():requested=requested/'index.html'
  if not requested.exists() and '.' not in pathlib.Path(suffix).name:requested=base/'index.html'
  return str(requested)
 def end_headers(self):
  self.send_header('Cache-Control','no-cache');super().end_headers()
print(f'Portfolio: http://localhost:{args.port}/\nDashboard: http://localhost:{args.port}/admin/',flush=True)
http.server.ThreadingHTTPServer(('127.0.0.1',args.port),Preview).serve_forever()
